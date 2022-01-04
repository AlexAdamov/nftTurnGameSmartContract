// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyEpicGame is ERC721, VRFConsumerBase {
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        string continent;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
        uint256 healingPoints; // you can heal other players with healingPoints
    }

    // Setting up the generator of tokenIds that uniquely identify each mitned NFT

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Array to hold default attributes for characters in the game
    CharacterAttributes[] defaultCharacters;

    // Array to store existing players
    string[] existingPlayers;

    // create a mapping from nft's tokenId to the NFT's attributes
    // and one from address to tohenIds to find the owner of an NFT easily
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;

    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);
    event PlayerHealed(
        uint256 newOtherPlayerHp,
        uint256 newPlayerHealingPoints
    );

    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    // Variables to get random number and make the impact of attacks variable
    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomResult;

    // data passed in to the contract when it initiliazes characters for first time
    // values will be passed from run.js

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        string[] memory characterContinents,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        uint256[] memory characterHealingPoints,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage
    )
        ERC721("GoodVibes Gladiators", "GOODVIBSGLAD")
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088 // LINK Token
        )
    {
        //Initialize the boss. Save it to global "bigBoss" state variable.

        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });
        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );

        // loop through all the characters, save their values in our contract
        // so we can use them later when we mint NFTs
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    continent: characterContinents[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i],
                    healingPoints: characterHealingPoints[i]
                })
            );

            CharacterAttributes memory c = defaultCharacters[i];

            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
            console.log(
                "--> %s comes from continent %s and has %s healing points",
                c.name,
                c.continent,
                c.healingPoints
            );
        }
        _tokenIds.increment();

        // Random number variables
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    //users can use this function to mint an NFT based
    // on the characterId they send (which character they choose)
    function mintCharacterNFT(uint256 _characterIndex) external {
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            continent: defaultCharacters[_characterIndex].continent,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            healingPoints: defaultCharacters[_characterIndex].healingPoints
        });

        console.log(
            "Minted NFT w/ tokenId %d and characterIndex %s",
            newItemId,
            _characterIndex
        );

        nftHolders[msg.sender] = newItemId;

        //increment tokenId for the next person to call the function
        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );
        string memory strHealingPoints = Strings.toString(
            charAttributes.healingPoints
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Win over Negativo!", "image": "ipfs://',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        '}, { "trait_type": "Healing Points", "value": ',
                        strHealingPoints,
                        "} ]}"
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss() public {
        // Get the state of the player's NFT.
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "\n Player w/ character %s has %s Healing Points",
            player.name,
            player.healingPoints
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );

        require(player.hp > 0, "Error: character must have HP to attack boss.");
        require(
            bigBoss.hp > 0,
            "Error: boss must have HP to be attacked by characters."
        );

        // Allow player to attack boss
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        // Allow boss to attack player.
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);

        emit AttackComplete(bigBoss.hp, player.hp);
    }

    function checkifUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        // Get the tokenID of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];
        // If the user has a tokenId in the map, return their character.
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    function getAllOtherPlayers()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        CharacterAttributes[]
            memory OtherPlayersAttributes = new CharacterAttributes[](
                _tokenIds.current() - 2
            );
        uint256 j = 0;
        for (uint256 i = 1; i < _tokenIds.current(); i++) {
            if (i != nftHolders[msg.sender]) {
                OtherPlayersAttributes[j] = nftHolderAttributes[i];
                j++;
            }
        }
        return OtherPlayersAttributes;
    }

    function healAnotherPlayer() public {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        uint256 nftTokenIdOfOtherPlayer;
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        console.log("nftTokenIdOfOtherPlayer", nftTokenIdOfOtherPlayer);
        if (nftTokenIdOfPlayer > 1) {
            nftTokenIdOfOtherPlayer = nftTokenIdOfPlayer - 1;
        } else {
            nftTokenIdOfOtherPlayer = nftTokenIdOfPlayer + 1;
        }

        console.log("nftTokenIdOfOtherPlayer", nftTokenIdOfOtherPlayer);

        CharacterAttributes storage otherPlayer = nftHolderAttributes[
            nftTokenIdOfOtherPlayer
        ];

        if (player.healingPoints > 50 && otherPlayer.hp != otherPlayer.maxHp) {
            otherPlayer.hp += 50;
            player.healingPoints -= 50;
        }

        console.log(
            "Player %s has healed player %s",
            player.name,
            otherPlayer.name
        );

        emit PlayerHealed(otherPlayer.hp, player.healingPoints);
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomResult = randomness;
        console.log("Random number is:", randomResult);
    }
}
