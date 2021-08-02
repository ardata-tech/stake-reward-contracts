const localDeployScript = async (deployer) => {};

const kovanDeployScript = async (deployer) => {};

const mainnetDeployScript = async (deployer) => {};

module.exports = async (deployer, network) => {
  console.log('Deploying to: ', network);

  switch (network) {
    case 'mainnet':
      await mainnetDeployScript(deployer);
      break;

    case 'kovan':
      await kovanDeployScript(deployer);
      break;

    case 'development':
    case 'develop':
    default:
      await localDeployScript(deployer);
  }
};

const toWei = (w) => web3.utils.toWei(w);

const MockERC20 = artifacts.require('MockERC20');
