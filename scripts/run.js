
const main = async () => {
    const [owner, address1, address2] = await ethers.getSigners();
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
        [
            "Creativa", //Character names
            "Curiousie",
            "Excitos",
            "Familia",
            "FriLocco",
            "Healthima",
            "Prouda",
            "Romantica",
            "Technogo"
        ],
        [
            "QmX36TJ9DkB6VXFoPdUY2ZdUETCJRpraYeFNaYYQ2z4LJk", // Images
            "QmQMc3KRAWYkdm1nbPp1TrSxceGpKSakGqTcYRX4qvcrC6",
            "QmPRiwmHYBcWjH8Cc1vC46DGzwZuk26euPz7B4WWRmnkk2",
            "QmcGJEyihXgwYfMXZz8oXfnbC8EmyPBcJCSh5JLcqNTWET",
            "QmUoDv8TTgSpAAw46eFRZchAir6qdNeH5La2zGec2pLaL6",
            "QmYKqqrJtjBbuJXAgHAXhfb1jeoKTA7Q1JUi4Btqv7WWGC",
            "QmRwBx8sd7fe2GUQYokEeoYViL2gYiuVJG8itX7oYy57KU",
            "QmRj9JgSk2awK92Kq5Ns67VuQaC3tsmnzSxJDGpVpS5xqt",
            "QmRDPg3rFLwH6TVQLyRFcGez7CXciMkWfHW9Mv55fVxnzT"
        ],
        [
            "Americas",
            "Asia",
            "Europe",
            "Africa",
            "Americas",
            "Africa",
            "Europe",
            "Asia",
            "Asia"
        ],
        [200, 300, 400, 200, 500, 300, 400, 200, 400], //HP values
        [100, 150, 50, 200, 100, 50, 250, 300, 100], // Attack damage values
        [100, 100, 200, 50, 100, 300, 200, 100, 100], //HealingPoints
        "Negativo", // Big Boss names
        "QmSusBj9558J9SgtGSPd4vvPaikQjhskSouGMs3m7TXJ8d", // Big Boss URI
        2000, // Big Boss Hp
        100 // Big Boss attack damage
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    let txn2;
    txn2 = await gameContract.connect(address1).mintCharacterNFT(4);
    await txn2.wait();

    let txn3;
    txn3 = await gameContract.connect(address2).mintCharacterNFT(3);
    await txn3.wait();

    // const defaultCharacters = await gameContract.getAllDefaultCharacters()
    // console.log("Default characters:", defaultCharacters)

    let otherPlayers = await gameContract.getAllOtherPlayers();
    console.log("Other existing players:", otherPlayers);

    let txn4;
    txn4 = await gameContract.connect(address1).attackBoss();
    await txn4.wait();

    let txn5;
    txn5 = await gameContract.connect(address2).attackBoss();
    await txn5.wait();

    otherPlayers = await gameContract.getAllOtherPlayers();
    console.log("Other existing players:", otherPlayers);

    let txn6;
    txn6 = await gameContract.healAnotherPlayers();
    await txn6.wait();

    otherPlayers = await gameContract.getAllOtherPlayers()
    console.log("Other existing players:", otherPlayers)
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();