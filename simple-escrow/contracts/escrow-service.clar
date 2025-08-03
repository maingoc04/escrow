;; title: escrow-service
;; version: 1.0.0
;; summary: Simple Escrow Service for secure transactions
;; description: A smart contract that enables secure transactions between buyers and sellers using escrow

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_ESCROW_NOT_FOUND (err u404))
(define-constant ERR_INVALID_STATUS (err u400))
(define-constant ERR_INSUFFICIENT_FUNDS (err u402))
(define-constant ERR_ALREADY_FUNDED (err u403))
(define-constant ERR_NOT_BUYER (err u405))
(define-constant ERR_NOT_SELLER (err u406))
(define-constant ERR_INVALID_AMOUNT (err u407))

;; Data Variables
(define-data-var next-escrow-id uint u1)
(define-data-var total-escrows uint u0)
(define-data-var total-volume uint u0)

;; Data Maps
(define-map escrows
  uint
  {
    buyer: principal,
    seller: principal,
    amount: uint,
    description: (string-ascii 256),
    status: (string-ascii 20),
    created-at: uint,
    funded-at: (optional uint),
    completed-at: (optional uint),
  }
)

(define-map user-escrow-count
  principal
  uint
)

;; Private Functions
(define-private (is-valid-status (status (string-ascii 20)))
  (or
    (is-eq status "CREATED")
    (is-eq status "FUNDED")
    (is-eq status "COMPLETED")
    (is-eq status "DISPUTED")
    (is-eq status "REFUNDED")
    (is-eq status "CANCELLED")
  )
)

;; Public Functions

;; Create a new escrow
(define-public (create-escrow
    (seller principal)
    (amount uint)
    (description (string-ascii 256))
  )
  (let ((escrow-id (var-get next-escrow-id)))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (not (is-eq tx-sender seller)) ERR_NOT_AUTHORIZED)

    (map-set escrows escrow-id {
      buyer: tx-sender,
      seller: seller,
      amount: amount,
      description: description,
      status: "CREATED",
      created-at: stacks-block-height,
      funded-at: none,
      completed-at: none,
    })

    ;; Update counters
    (var-set next-escrow-id (+ escrow-id u1))
    (var-set total-escrows (+ (var-get total-escrows) u1))

    ;; Update user escrow count
    (map-set user-escrow-count tx-sender
      (+ (default-to u0 (map-get? user-escrow-count tx-sender)) u1)
    )

    (ok escrow-id)
  )
)

;; Fund an existing escrow
(define-public (fund-escrow (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) ERR_ESCROW_NOT_FOUND)))
    (asserts! (is-eq (get buyer escrow) tx-sender) ERR_NOT_BUYER)
    (asserts! (is-eq (get status escrow) "CREATED") ERR_INVALID_STATUS)

    ;; Transfer STX to contract
    (try! (stx-transfer? (get amount escrow) tx-sender (as-contract tx-sender)))

    ;; Update escrow status
    (map-set escrows escrow-id
      (merge escrow {
        status: "FUNDED",
        funded-at: (some stacks-block-height),
      })
    )

    ;; Update total volume
    (var-set total-volume (+ (var-get total-volume) (get amount escrow)))

    (ok true)
  )
)

;; Confirm delivery and release funds
(define-public (confirm-delivery (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) ERR_ESCROW_NOT_FOUND)))
    (asserts! (is-eq (get buyer escrow) tx-sender) ERR_NOT_BUYER)
    (asserts! (is-eq (get status escrow) "FUNDED") ERR_INVALID_STATUS)

    ;; Transfer funds to seller
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get seller escrow))))

    ;; Update escrow status
    (map-set escrows escrow-id
      (merge escrow {
        status: "COMPLETED",
        completed-at: (some stacks-block-height),
      })
    )

    (ok true)
  )
)

;; Dispute an escrow (simplified - just marks as disputed)
(define-public (dispute-escrow (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) ERR_ESCROW_NOT_FOUND)))
    (asserts!
      (or
        (is-eq (get buyer escrow) tx-sender)
        (is-eq (get seller escrow) tx-sender)
      )
      ERR_NOT_AUTHORIZED
    )
    (asserts! (is-eq (get status escrow) "FUNDED") ERR_INVALID_STATUS)

    ;; Update escrow status
    (map-set escrows escrow-id (merge escrow { status: "DISPUTED" }))

    (ok true)
  )
)

;; Cancel escrow (only if not funded)
(define-public (cancel-escrow (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) ERR_ESCROW_NOT_FOUND)))
    (asserts! (is-eq (get buyer escrow) tx-sender) ERR_NOT_BUYER)
    (asserts! (is-eq (get status escrow) "CREATED") ERR_INVALID_STATUS)

    ;; Update escrow status
    (map-set escrows escrow-id (merge escrow { status: "CANCELLED" }))

    (ok true)
  )
)

;; Refund escrow (for disputes - simplified admin function)
(define-public (refund-escrow (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) ERR_ESCROW_NOT_FOUND)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status escrow) "DISPUTED") ERR_INVALID_STATUS)

    ;; Refund to buyer
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get buyer escrow))))

    ;; Update escrow status
    (map-set escrows escrow-id
      (merge escrow {
        status: "REFUNDED",
        completed-at: (some stacks-block-height),
      })
    )

    (ok true)
  )
)

;; Read-only functions

;; Get escrow details
(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows escrow-id)
)

;; Get user's escrow count
(define-read-only (get-user-escrow-count (user principal))
  (default-to u0 (map-get? user-escrow-count user))
)

;; Get contract stats
(define-read-only (get-contract-stats)
  {
    total-escrows: (var-get total-escrows),
    total-volume: (var-get total-volume),
    next-escrow-id: (var-get next-escrow-id),
  }
)

;; Check if user is buyer of escrow
(define-read-only (is-buyer
    (escrow-id uint)
    (user principal)
  )
  (match (map-get? escrows escrow-id)
    escrow (is-eq (get buyer escrow) user)
    false
  )
)

;; Check if user is seller of escrow
(define-read-only (is-seller
    (escrow-id uint)
    (user principal)
  )
  (match (map-get? escrows escrow-id)
    escrow (is-eq (get seller escrow) user)
    false
  )
)
