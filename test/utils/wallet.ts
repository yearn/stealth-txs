import { Wallet } from 'ethers';
import { ethers, network } from 'hardhat';
import { JsonRpcSigner } from '@ethersproject/providers';
import { getAddress } from 'ethers/lib/utils';
import { randomHex } from 'web3-utils';

const impersonate = async (address: string): Promise<JsonRpcSigner> => {
  await network.provider.request({
    method: 'hardhat_impersonateAccount',
    params: [address],
  });
  await ethers.provider.send('hardhat_setBalance', [address, '0xffffffffffffffff']);
  return ethers.provider.getSigner(address);
};
const generateRandom = async () => {
  const wallet = (await Wallet.createRandom()).connect(ethers.provider);
  await ethers.provider.send('hardhat_setBalance', [wallet.address, '0xffffffffffffffff']);
  return wallet;
};

const generateRandomAddress = () => {
  return getAddress(randomHex(20));
};

export default {
  impersonate,
  generateRandom,
  generateRandomAddress,
};
