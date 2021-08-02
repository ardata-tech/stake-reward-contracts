const Migrations = artifacts.require("Migrations");
const EDIPI = artifacts.require("EDIPI");
const MasterChef = artifacts.require("StakerMinter");
module.exports = async(deployer) => {
    await deployer.deploy(Migrations);
    const EDIP = await deployer.deploy(EDIPI);
    const Master = await deployer.deploy(MasterChef, EDIP.address);
    const ownerShip = await EDIP.transferOwnership(Master.address);
    console.log(ownerShip.address);
};