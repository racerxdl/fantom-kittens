
const chai = require("chai")
const expect = chai.expect
const { solidity } = require("ethereum-waffle");

chai.use(solidity)

describe("FantomKittens contract", function () {
  let owner;
  let depositAddress;
  let someFucker;

  this.beforeAll(async () => {
    [owner, depositAddress, someFucker] = await ethers.getSigners();
  })

  it("should mint a token properly and transfer amount to deposit address", async function () {
    const depositAddressInitialBalance = await depositAddress.getBalance()
    const Contract = await ethers.getContractFactory("FantomKittens");

    const contract = await Contract.deploy();

    await contract.setDepositAddress(await depositAddress.getAddress())

    const receipt = await contract.claim(ethers.BigNumber.from(42), {
      value: ethers.utils.parseEther("42.0"),
    }).catch(e => e.message)

    expect(receipt).to.not.equal(`VM Exception while processing transaction: reverted with reason string 'Invalid amount'`)
    expect(await depositAddress.getBalance()).to.equal(ethers.utils.parseEther("42").add(depositAddressInitialBalance))
    expect(await contract.balanceOf(await owner.getAddress())).to.equal(1)
  });


  it("should not mint if user didn't send the right amount", async function () {
    const Contract = await ethers.getContractFactory("FantomKittens");

    const contract = await Contract.deploy();

    await contract.setDepositAddress(await depositAddress.getAddress())

    const receipt = await contract.claim(ethers.BigNumber.from(1), {
      value: ethers.utils.parseEther("2.0"),
    }).catch(e => e.message)

    expect(receipt).to.equal(`VM Exception while processing transaction: reverted with reason string 'Invalid amount'`)
  });

  it("only contract owner should change the deposit address", async function () {
    const Contract = await ethers.getContractFactory("FantomKittens");

    const contract = await Contract.deploy();

    const contractFuckerSigner = contract.connect(someFucker)

    const receipt = await contractFuckerSigner.setDepositAddress(await someFucker.getAddress()).catch(e => e.message)

    expect(receipt).to.equal(`VM Exception while processing transaction: reverted with reason string 'Ownable: caller is not the owner'`)
  });

  it("should revert invalid token claim", async function () {
    const Contract = await ethers.getContractFactory("FantomKittens");

    const contract = await Contract.deploy();

    await contract.setDepositAddress(await depositAddress.getAddress())

    const contractFuckerSigner = contract.connect(someFucker)

    const _ = await contract.claim(ethers.BigNumber.from(42), {
      value: ethers.utils.parseEther("42.0"),
    }).catch(e => e.message)

    const receipt = await contractFuckerSigner.claim(ethers.BigNumber.from(42), {
      value: ethers.utils.parseEther("42.0"),
    }).catch(e => e.message)

    console.log(receipt)

    expect(receipt).to.equal(`VM Exception while processing transaction: reverted with reason string 'ERC721: token already minted'`)
    expect(await contractFuckerSigner.balanceOf(await someFucker.getAddress())).to.equal(0)
  });

});