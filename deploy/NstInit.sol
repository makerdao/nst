// SPDX-FileCopyrightText: © 2023 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.8.0;

import { DssInstance } from "dss-test/MCD.sol";
import { NstInstance } from "./NstInstance.sol";

interface NstLike {
    function rely(address) external;
    function deny(address) external;
}

interface NstJoinLike {
    function nst() external view returns (address);
}

interface DaiNstLike {
    function daiJoin() external view returns (address);
    function nstJoin() external view returns (address);
}

library NstInit {
    function init(
        DssInstance memory dss,
        NstInstance memory instance
    ) internal {
        require(NstJoinLike(instance.nstJoin).nst() == instance.nst, "NstInit/nst-does-not-match");

        address daiJoin = dss.chainlog.getAddress("MCD_JOIN_DAI");
        require(DaiNstLike(instance.daiNst).daiJoin() == daiJoin, "NstInit/daiJoin-does-not-match");
        require(DaiNstLike(instance.daiNst).nstJoin() == instance.nstJoin, "NstInit/nstJoin-does-not-match");

        NstLike(instance.nst).rely(instance.nstJoin);
        NstLike(instance.nst).deny(instance.owner);

        dss.chainlog.setAddress("NST",     instance.nst);
        dss.chainlog.setAddress("NSTJOIN", instance.nstJoin);
        dss.chainlog.setAddress("DAINST",  instance.daiNst);
    }
}
