// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Prover {
    uint256 constant FIELD_MODULUS =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // G₁
    G1Point G1 = G1Point(1, 2);
    // A₁
    G1Point Alpha1 = G1Point(
        4312786488925573964619847916436127219510912864504589785209181363209026354996,
        16161347681839669251864665467703281411292235435048747094987907712909939880451
    );
    // B₂
    G2Point Beta2 = G2Point(
        [
            17296964631866875666414577250007729606613623754163522903713032490388223445037,
            1283677034539803510874027931207865251280207678130679415321551268807544273576
        ],
        [
            13812093994560590184820145872054776567171925844569160955348410196240330134586,
            8936292128759031376286991047402535836794406876407098545227428235741625269642
        ]
    );
    // γ₂
    G2Point Gamma2 = G2Point(
        [
            1209893991840828154329287693451509834776218515637762472720039267463067126632,
            9106207040409315987478311070910458124079543814309976583950075672144273288029
        ],
        [
            9023851771460371829246467073157895169294109351952181673323749370713410091757,
            4252905859092308102621098998074649916784325417478384658390937991502825859612
        ]
    );
    // δ₂
    G2Point Delta2 = G2Point(
        [
            12395238526165366537091172838857376279080808457805495135933642393067303462498,
            21296194300409337184467126358007341406168853906258016846128333089639414174695
        ],
        [
            18951055611494008410955520697524221579291737862362995692470931173837825867435,
            5928178988285113031387381108741531542232165426631867190685674604280144157667
        ]
    );

    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        uint256[2] x; // [x1, x2]
        uint256[2] y; // [y1, y2]
    }

    function scalarMultiplyPoint(
        G1Point memory P,
        uint256 s
    ) public view returns (G1Point memory) {
        (bool success, bytes memory result) = address(7).staticcall(
            abi.encode(P.x, P.y, s)
        );
        require(success, "Prover: point scalar multiplication failed.");

        (uint256 x, uint256 y) = abi.decode(result, (uint256, uint256));
        return G1Point(x, y);
    }

    function negatePoint(
        G1Point memory P
    ) public pure returns (G1Point memory) {
        // If point at infinity
        if (P.x == 0 && P.y == 0) {
            return G1Point(0, 0);
        } else {
            // Additive inverse of P (reflected over x-axis)
            return G1Point(P.x, FIELD_MODULUS - (P.y % FIELD_MODULUS));
        }
    }

    function verify(
        G1Point calldata A1,
        G2Point calldata B2,
        G1Point calldata C1,
        uint256 x1,
        uint256 x2,
        uint256 x3
    ) public view returns (bool) {
        // Compute X₁ = x₁G₁ + x₂G₁ + x₃G₁
        G1Point memory X1 = scalarMultiplyPoint(G1, x1 + x2 + x3);

        // Verify the equality 0 = -A₁B₂ + α₁β₂ + X₁γ₂ + C₁δ₂
        G1Point memory neg_A1 = negatePoint(A1);
        uint256[24] memory input = [
            // -A₁B₂
            neg_A1.x,
            neg_A1.y,
            B2.x[1],
            B2.x[0],
            B2.y[1],
            B2.y[0],
            // α₁β₂
            Alpha1.x,
            Alpha1.y,
            Beta2.x[1],
            Beta2.x[0],
            Beta2.y[1],
            Beta2.y[0],
            // X₁γ₂
            X1.x,
            X1.y,
            Gamma2.x[1],
            Gamma2.x[0],
            Gamma2.y[1],
            Gamma2.y[0],
            // C₁δ₂
            C1.x,
            C1.y,
            Delta2.x[1],
            Delta2.x[0],
            Delta2.y[1],
            Delta2.y[0]
        ];

        assembly {
            let success := staticcall(
                gas(),
                8,
                input,
                mul(24, 0x20),
                input,
                0x20
            )
            if success {
                return(input, 0x20)
            }
        }

        return false;
    }
}
