# 🔒 Project 10: Simple Escrow Service

## 📋 Tổng Quan

**Simple Escrow Service** là một smart contract đơn giản trên Stacks blockchain giúp thực hiện giao dịch an toàn giữa người mua và người bán thông qua cơ chế ký quỹ (escrow).

### 🎯 Vấn Đề Giải Quyết
- Giao dịch trực tuyến thiếu tin cậy
- Người mua sợ mất tiền mà không nhận được hàng
- Người bán sợ giao hàng mà không được thanh toán
- Cần bên thứ 3 trung gian đáng tin cậy

### 💡 Giải Pháp
Smart contract escrow tự động:
- Người mua gửi tiền vào escrow
- Người bán giao hàng/dịch vụ
- Người mua xác nhận đã nhận
- Tiền được tự động chuyển cho người bán
- Nếu có tranh chấp, có cơ chế giải quyết

## 🏗️ Kiến Trúc

### Smart Contract Functions

#### Public Functions
- `create-escrow` - Tạo escrow mới
- `fund-escrow` - Gửi tiền vào escrow
- `confirm-delivery` - Xác nhận đã nhận hàng
- `dispute-escrow` - Tạo tranh chấp
- `cancel-escrow` - Hủy escrow (chỉ khi chưa fund)
- `refund-escrow` - Hoàn tiền (admin function)

#### Read-Only Functions
- `get-escrow` - Lấy thông tin escrow
- `get-user-escrow-count` - Đếm số escrow của user
- `get-contract-stats` - Thống kê contract
- `is-buyer` - Kiểm tra user có phải buyer
- `is-seller` - Kiểm tra user có phải seller

### Escrow States
1. **CREATED** - Escrow được tạo, chưa fund
2. **FUNDED** - Buyer đã gửi tiền vào
3. **COMPLETED** - Buyer confirm, seller nhận tiền
4. **DISPUTED** - Có tranh chấp, cần giải quyết
5. **REFUNDED** - Tiền được hoàn lại buyer
6. **CANCELLED** - Escrow bị hủy

## 🚀 Quick Start

### Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet) installed
- Node.js và npm
- Stacks wallet (for frontend)

### Setup & Testing

```bash
# Clone và setup
cd project10_simple_escrow/simple-escrow

# Install dependencies
npm install

# Check contract syntax
clarinet check

# Run tests
npm test

# Deploy to devnet (optional)
clarinet deploy --devnet
```

## 📖 Usage Examples

### 1. Tạo Escrow Mới
```clarity
;; Buyer tạo escrow với seller
(contract-call? .escrow-service create-escrow 
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG  ;; seller address
  u1000000                                      ;; 1 STX
  "Laptop Dell XPS 13")                        ;; description
```

### 2. Fund Escrow
```clarity
;; Buyer gửi tiền vào escrow
(contract-call? .escrow-service fund-escrow u1)
```

### 3. Confirm Delivery
```clarity
;; Buyer xác nhận đã nhận hàng
(contract-call? .escrow-service confirm-delivery u1)
```

### 4. Get Escrow Info
```clarity
;; Xem thông tin escrow
(contract-call? .escrow-service get-escrow u1)
```

## 🔧 Development

### Project Structure
```
project10_simple_escrow/
├── simple-escrow/
│   ├── contracts/
│   │   └── escrow-service.clar
│   ├── tests/
│   │   └── escrow-service.test.ts
│   ├── settings/
│   │   ├── Devnet.toml
│   │   ├── Testnet.toml
│   │   └── Mainnet.toml
│   ├── Clarinet.toml
│   ├── package.json
│   └── tsconfig.json
├── README.md
└── project10_escrow_service_plan.md
```

### Testing
Contract đã được test với các scenarios:
- ✅ Tạo escrow thành công
- ✅ Lấy thông tin escrow
- ✅ Lấy thống kê contract
- ✅ Kiểm tra authorization

### Security Features
- Only buyer có thể fund escrow
- Only buyer có thể confirm delivery
- Both parties có thể dispute
- Funds locked safely trong contract
- Admin có thể resolve disputes

## 🎪 Demo Flow

### Complete Escrow Flow
1. **Create** - Buyer tạo escrow với seller address và amount
2. **Fund** - Buyer gửi STX vào contract
3. **Deliver** - Seller giao hàng/dịch vụ
4. **Confirm** - Buyer xác nhận đã nhận
5. **Complete** - Funds tự động chuyển cho seller

### Error Handling
- `ERR_NOT_AUTHORIZED (401)` - Không có quyền
- `ERR_ESCROW_NOT_FOUND (404)` - Không tìm thấy escrow
- `ERR_INVALID_STATUS (400)` - Trạng thái không hợp lệ
- `ERR_NOT_BUYER (405)` - Không phải buyer
- `ERR_INVALID_AMOUNT (407)` - Số tiền không hợp lệ

## 🌟 Features

### ✅ Implemented
- Basic escrow creation và funding
- Delivery confirmation
- Dispute mechanism (basic)
- Contract statistics
- Comprehensive error handling
- Unit tests

### 🔄 Future Enhancements
- Frontend React app
- Multi-signature disputes
- Escrow templates
- Fee mechanism
- Time-based auto-release
- Integration với marketplaces

## 📊 Contract Stats

Theo dõi:
- Total escrows created
- Total volume processed
- Next escrow ID
- User escrow counts

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Add tests for new features
4. Ensure all tests pass
5. Submit pull request


Built with ❤️ for hackathon participants và blockchain developers.
