const { loadFixture } =  require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')

describe("Prover", function() {
  async function deployProverFixture() {
    const Prover = await ethers.getContractFactory("Prover")
    const prover = await Prover.deploy()

    return { prover }
  }

  describe("Crypto", function() {
    it("Should return true", async function() {
      const { prover } = await loadFixture(deployProverFixture)

      const A1 = [
        ethers.BigNumber.from('10744596414106452074759370245733544594153395043370666422502510773307029471145'),
        ethers.BigNumber.from('848677436511517736191562425154572367705380862894644942948681172815252343932')
      ]
      const B2 = [
        [
          ethers.BigNumber.from('10191129150170504690859455063377241352678147020731325090942140630855943625622'),
          ethers.BigNumber.from('16727484375212017249697795760885267597317766655549468217180521378213906474374')
        ],
        [
          ethers.BigNumber.from('12345624066896925082600651626583520268054356403303305150512393106955803260718'),
          ethers.BigNumber.from('13790151551682513054696583104432356791070435696840691503641536676885931241944')
        ]
      ]
      const C1 = [
        ethers.BigNumber.from('1368015179489954701390400359078579693043519447331113978918064868415326638035'),
        ethers.BigNumber.from('9918110051302171585080402603319702774565515993150576347155970296011118125764')
      ]
      const x1 = 1
      const x2 = 1
      const x3 = 1

      expect(await prover.verify(A1, B2, C1, x1, x2, x3)).to.be.equal(true)
    })
  })
})
