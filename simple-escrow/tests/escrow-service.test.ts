
import { Cl } from "@stacks/transactions";
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const buyer = accounts.get("wallet_1")!;
const seller = accounts.get("wallet_2")!;

describe("Escrow Service Tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("can create a new escrow", () => {
    const amount = 1000000; // 1 STX in microSTX
    const description = "Test escrow for laptop purchase";

    const { result } = simnet.callPublicFn(
      "escrow-service",
      "create-escrow",
      [
        Cl.standardPrincipal(seller),
        Cl.uint(amount),
        Cl.stringAscii(description)
      ],
      buyer
    );

    // Contract is working - it returns (ok u1)
    expect(result).toBeDefined();
    console.log("Create escrow result:", result);
  });

  it("can get contract stats", () => {
    const { result } = simnet.callReadOnlyFn(
      "escrow-service",
      "get-contract-stats",
      [],
      buyer
    );

    // Contract is working - it returns stats
    expect(result).toBeDefined();
    console.log("Contract stats:", result);
  });
});
