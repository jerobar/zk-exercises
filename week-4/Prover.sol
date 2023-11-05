// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

contract Prover {
    uint256 constant CURVE_ORDER =
        0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001;

    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        uint256[2] x;
        uint256[2] y;
    }

    // G1
    G1Point G1 = G1Point(1, 2);
    // A₁
    G1Point Alpha_1 =
        G1Point(
            5138697240077803445514669414784254799933862402946278134326199877546184124353,
            12587011617949543324467535889916856826666519601316494966427400843934921824601
        );
    // B₂
    G2Point Beta_2 =
        G2Point(
            [
                15380484938200814403881087981412294620100873432818036673589291147845024225571,
                12602109964935088016887987406157853419623515645637587704176662081914411301318
            ],
            [
                18666296425544234789562310040634234422589269469188454772496605606699412541097,
                5196377417757280559932251044816639832790442126146965060826533782304458949952
            ]
        );
    // γ₂
    G2Point Gamma_2 =
        G2Point(
            [
                16533935655882508933200494473493224172137214331738653888303739254278392816139,
                18880978986792929021469791843695392603128946481846666271410481427998908587420
            ],
            [
                13141448804549710154358653194644535861993981907731549996410137978037004389569,
                9762548523825741675364125428211388275252455058307432435140067326598456040331
            ]
        );
    // δ₂
    G2Point Detla_2 =
        G2Point(
            [
                10162338589393961187840690440736730403643501083670401659044175493788672801975,
                15778097377978213295342357580990122748603225141808559681543747573981325835864
            ],
            [
                10296903209504479081730603432149203031278495964641591619128682912272764993749,
                18440560316284345279041150568082080240188217139841085848344914718164626752030
            ]
        );

    function addPoints(
        G1Point memory A,
        G1Point memory B
    ) public view returns (G1Point memory) {
        (bool success, bytes memory result) = address(6).staticcall(
            abi.encode(A.x, A.y, B.x, B.y)
        );
        require(success, "Prover: point addition failed.");

        (uint256 x, uint256 y) = abi.decode(result, (uint256, uint256));
        return G1Point(x, y);
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
        if (P.x == 0 && P.y == 0) {
            return G1Point(0, 0);
        } else {
            // Additive inverse of P (reflected over x-axis)
            return G1Point(P.x, CURVE_ORDER - (P.y % CURVE_ORDER));
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
        // Compute X1 = x1G1 + x2G1 + x3G1
        G1Point memory X1 = addPoints(
            addPoints(scalarMultiplyPoint(G1, x1), scalarMultiplyPoint(G1, x2)),
            scalarMultiplyPoint(G1, x3)
        );

        // Verify the equality 0 = -A₁B₂ + α₁β₂ + X₁γ₂ + C₁δ₂
        G1Point memory neg_A1 = negatePoint(A1);
        uint256[] memory input = new uint256[](24);
        // -A₁B₂
        input[0] = neg_A1.x;
        input[1] = neg_A1.y;
        input[2] = B2.x[0];
        input[3] = B2.x[1];
        input[4] = B2.y[0];
        input[5] = B2.y[1];
        // α₁β₂
        input[6] = Alpha_1.x;
        input[7] = Alpha_1.y;
        input[8] = Beta_2.x[0];
        input[9] = Beta_2.x[1];
        input[10] = Beta_2.y[0];
        input[11] = Beta_2.y[1];
        // X₁γ₂
        input[12] = X1.x;
        input[13] = X1.y;
        input[14] = Gamma_2.x[0];
        input[15] = Gamma_2.x[1];
        input[16] = Gamma_2.y[0];
        input[17] = Gamma_2.y[1];
        // C₁δ₂
        input[18] = C1.x;
        input[19] = C1.y;
        input[20] = Detla_2.x[0];
        input[21] = Detla_2.x[1];
        input[22] = Detla_2.y[0];
        input[23] = Detla_2.y[1];

        assembly {
            let success := staticcall(gas(), 8, add(input, 0x20), mul(24, 0x20), input, 0x20)
            if success {
                return(input, 0x20)
            }
        }

        return false;
    }
}
