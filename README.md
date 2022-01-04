# NFT Turn based game - Smart Contract

This a turn based game where the goal is to beat a Boss called Nagativo by sending him good vibes :-). 
Users mint an NFT player Character from 9 character types then proceed to the Arena to challenge Negativo. Each hit by the playing character is reciprocated by a hit from the Boss. 
A player has the ability to heal other players who may have created a playing character as well.

# How to deploy the game:
This game was developed with hardhat, a development framework for smart contracts written in Solidity

Shell commands (Assumes yarn, Javascript package manager, is installed) 
```
yarn add hardhat --dev
yarn add @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers --dev
yarnn add @openzeppelin/contracts
```

to deploy the smart contract, run the deploy contract from the project folder with the shell command below. To enable it you need to set-up a metamask wallet and get rinkeby test ETH on the wallet. Steps provided here https://www.youtube.com/watch?v=wbv7telXcFw
```
yarn run hardhat scripts/deploy.js --network rinkeby
```

# Front-end
This game is best played with the front-end developed in conjuntion: https://github.com/AlexAdamov/NftTurnGameFrontEnd

# Reference and features added
The project is based on a tutorial made by Buildspace https://buildspace.so/. I added the following features:

* Ability to view other players
* Ability to heal other players
