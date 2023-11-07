// SPDX-License-Identifier: MIT

// pragma solidity 0.8.22;
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Prover {
	uint256 constant FIELD_MODULUS = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        uint256[2] x; // [x1, x2]
        uint256[2] y; // [y1, y2]
    }

    // G₁
    G1Point G1 = G1Point(1, 2);
    // A₁
    // G1Point Alpha1 =
    //     G1Point(
    //         15727213640762128376977790067421582934261473041285176203873887513123693207669,
    //         19144605879150273414601776380457513460094228635793066771119021730299648624873
    //     );
    G1Point Alpha1 = G1Point(
        1368015179489954701390400359078579693043519447331113978918064868415326638035,
        9918110051302171585080402603319702774565515993150576347155970296011118125764
    );
    // B₂
    // G2Point Beta2 =
    //     G2Point(
    //         [
    //             14723447415878424720010269203225520894960735394327153370593999433287005836180,
    //             11811455205613046277338997666037446642341379735809759775117747578677599454011
    //         ],
    //         [
    //             849931228475731710848854335459231361797353585262966996652302040119408313869,
    //             21131339677253941101883175242832208139150781082220787719353536261069675551205
    //         ]
    //     );
    G2Point Beta2 = G2Point(
        [
            2725019753478801796453339367788033689375851816420509565303521482350756874229,
            7273165102799931111715871471550377909735733521218303035754523677688038059653
        ],
        [
            2512659008974376214222774206987427162027254181373325676825515531566330959255,
            957874124722006818841961785324909313781880061366718538693995380805373202866
        ]
    );
    // γ₂
    // G2Point Gamma2 =
    //     G2Point(
    //         [
    //             16533935655882508933200494473493224172137214331738653888303739254278392816139,
    //             18880978986792929021469791843695392603128946481846666271410481427998908587420
    //         ],
    //         [
    //             13141448804549710154358653194644535861993981907731549996410137978037004389569,
    //             9762548523825741675364125428211388275252455058307432435140067326598456040331
    //         ]
    //     );
    G2Point Gamma2 = G2Point(
        [
            18936818173480011669507163011118288089468827259971823710084038754632518263340,
            18556147586753789634670778212244811446448229326945855846642767021074501673839
        ],
        [
            18825831177813899069786213865729385895767511805925522466244528695074736584695,
            13775476761357503446238925910346030822904460488609979964814810757616608848118
        ]
    );
    // δ₂
    // G2Point Delta2 =
    //     G2Point(
    //         [
    //             10162338589393961187840690440736730403643501083670401659044175493788672801975,
    //             15778097377978213295342357580990122748603225141808559681543747573981325835864
    //         ],
    //         [
    //             10296903209504479081730603432149203031278495964641591619128682912272764993749,
    //             18440560316284345279041150568082080240188217139841085848344914718164626752030
    //         ]
    //     );
    G2Point Delta2 = G2Point(
        [
            10191129150170504690859455063377241352678147020731325090942140630855943625622,
            12345624066896925082600651626583520268054356403303305150512393106955803260718
        ],
        [
            16727484375212017249697795760885267597317766655549468217180521378213906474374,
            13790151551682513054696583104432356791070435696840691503641536676885931241944
        ]
    );

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
        G1Point memory A1,
        G2Point memory B2,
        G1Point memory C1,
        uint256 x1,
        uint256 x2,
        uint256 x3
    ) public view returns (bool) {
        // Compute X₁ = x₁G₁ + x₂G₁ + x₃G₁
        // G1Point memory X1 = scalarMultiplyPoint(G1, x1 + x2 + x3); // correct
        G1Point memory X1 = G1Point(
            3353031288059533942658390886683067124040920775575537747144343083137631628272,
            19321533766552368860946552437480515441416830039777911637913418824951667761761
        );

        // Verify the equality 0 = -A₁B₂ + α₁β₂ + X₁γ₂ + C₁δ₂
        // G1Point memory neg_A1 = negatePoint(A1); // correct
        G1Point memory neg_A1 = G1Point(
            10744596414106452074759370245733544594153395043370666422502510773307029471145, 
            21039565435327757486054843320102702720990930294403178719740356721829973864651
        );

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

        console.log('neg_A1.x', input[0]);
        console.log('neg_A1.y', input[1]);
        console.log("B2.x2", input[2]);
        console.log("B2.x1", input[3]);
        console.log("B2.y2", input[4]);
        console.log("B2.y1", input[5]);

        console.log('Alpha1.x', input[6]);
        console.log('Alpha1.y', input[7]);
        console.log("Beta2.x2", input[8]);
        console.log("Beta2.x1", input[9]);
        console.log("Beta2.y2", input[10]);
        console.log("Beta2.y1", input[11]);

        console.log('X1.x', input[12]);
        console.log('X1.y', input[13]);
        console.log("Gamma2.x2", input[14]);
        console.log("Gamma2.x1", input[15]);
        console.log("Gamma2.y2", input[16]);
        console.log("Gamma2.y1", input[17]);

        console.log('C1.x', input[18]);
        console.log('C1.y', input[19]);
        console.log("Delta2.x2", input[20]);
        console.log("Delta2.x1", input[21]);
        console.log("Delta2.y2", input[22]);
        console.log("Delta2.y1", input[23]);

        bool success = false;

        assembly {
            success := staticcall(gas(), 8, input, mul(24, 0x20), input, 0x20)
            if success { return(input, 0x20) }
        }

        console.log("staticcall success:", success);

        return false;

        // assembly {
        //     success := staticcall(gas(), 8, input, mul(24, 0x20), input, 0x20)
        //     if success {
        //         return(input, 0x20)
        //     }
        // }

        // return false;
    }
}
