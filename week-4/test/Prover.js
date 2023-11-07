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
        ethers.BigNumber.from('5138697240077803445514669414784254799933862402946278134326199877546184124353'),
        ethers.BigNumber.from('12587011617949543324467535889916856826666519601316494966427400843934921824601')
      ]
      const B2 = [
        [
          ethers.BigNumber.from('15380484938200814403881087981412294620100873432818036673589291147845024225571'),
          ethers.BigNumber.from('12602109964935088016887987406157853419623515645637587704176662081914411301318')
        ],
        [
          ethers.BigNumber.from('18666296425544234789562310040634234422589269469188454772496605606699412541097'),
          ethers.BigNumber.from('5196377417757280559932251044816639832790442126146965060826533782304458949952')
        ]
      ]
      const C1 = [
        ethers.BigNumber.from('18115820847719354145006839277460497036449957002389237515059446258175487520785'),
        ethers.BigNumber.from('19209692151171434733578266993807762700657408369289225451789154294457672577583')
      ]
      const x1 = 13
      const x2 = 18
      const x3 = 29

      expect(await prover.verify(A1, B2, C1, x1, x2, x3)).to.be.equal(true)
    })
  })
})
