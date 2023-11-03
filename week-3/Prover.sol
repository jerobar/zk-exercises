// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

contract Prover {
    uint256 constant CURVE_ORDER =
        0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001;

    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    ECPoint G1 = ECPoint(1, 2);

    function addPoints(
        ECPoint memory A,
        ECPoint memory B
    ) public view returns (ECPoint memory C) {
        (bool success, bytes memory result) = address(6).staticcall(
            abi.encode(A.x, A.y, B.x, B.y)
        );
        require(success, "Prover: point addition failed.");

        (uint256 x, uint256 y) = abi.decode(result, (uint256, uint256));
        C = ECPoint(x, y);
    }

    function scalarMultiplyPoint(
        ECPoint memory P,
        uint256 s
    ) public view returns (ECPoint memory R) {
        (bool success, bytes memory result) = address(7).staticcall(
            abi.encode(P.x, P.y, s)
        );
        require(success, "Prover: point scalar multiplication failed.");

        (uint256 x, uint256 y) = abi.decode(result, (uint256, uint256));
        R = ECPoint(x, y);
    }

    function rationalAdd(
        ECPoint calldata A,
        ECPoint calldata B,
        uint256 num,
        uint256 den
    ) public view returns (bool verified) {
        ECPoint memory P1 = scalarMultiplyPoint(
            G1,
            num * invMod(den, CURVE_ORDER)
        );
        ECPoint memory P2 = addPoints(A, B);

        verified = (P1.x == P2.x) && (P1.y == P2.y);
    }

    function matmul(
        uint256[] calldata matrix,
        uint256 n,
        ECPoint[] calldata s,
        uint256[] calldata o
    ) public view returns (bool) {
        // Ensure the provided dimensions make sense
        require(
            (matrix.length == n * n) && (s.length == n) && (o.length == n),
            "Prover: Dimensions don't make sense."
        );

        // For each element in the 1xn product of matrix * s
        for (uint256 i = 0; i < n; i++) {
            ECPoint memory result;

            // Calculate the element
            for (uint256 j = 0; j < n; j++) {
                if (j == 0) {
                    result = scalarMultiplyPoint(s[j], matrix[j * n + i]);
                } else {
                    result = addPoints(
                        result,
                        scalarMultiplyPoint(s[j], matrix[j * n + i])
                    );
                }
            }

            // Check each calculated element against its counterpart in o
            ECPoint memory O = scalarMultiplyPoint(G1, o[i]);

            // If a calculated element doesn't match its counterpart, return false
            if (O.x != result.x || O.y != result.y) {
                return false;
            }
        }

        return true;
    }

    function invMod(uint256 _x, uint256 _pp) public pure returns (uint256) {
        require(_x != 0 && _x != _pp && _pp != 0, "Invalid number");
        uint256 q = 0;
        uint256 newT = 1;
        uint256 r = _pp;
        uint256 t;
        while (_x != 0) {
            t = r / _x;
            (q, newT) = (newT, addmod(q, (_pp - mulmod(t, newT, _pp)), _pp));
            (r, _x) = (_x, r - t * _x);
        }

        return q;
    }
}
