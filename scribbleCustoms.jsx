import React, { useState, useEffect, useRef, useCallback } from "react";
import Select from "react-select";
import Card from "../Card";
import traits from "../../traits";
import nftombstoneData from "../../contracts/nftombstoneMetadata.json";
import { useMoralis, useWeb3ExecuteFunction } from "react-moralis";
import Moralis from "moralis";
import Authenticate from "../Authenticate";
import spotNFTAbi from "../../contracts/spotNFTAbi.json";
import spotTraitsAbi from "../../contracts/spotTraitsAbi.json";
import SetApproval from "../SetApproval";
import ScribbleMint from "../ScribbleMint";
import "../../Board.css";
import nfTombstoneABI from "../../contracts/nfTombstoneABI.json";
import axios from "axios";
import MintCollection from "../MintCollection";
import { TOMBSTONE_ADDRESS } from "../Contracts/TombstoneContract";
import image1 from "../../assets/scribble/CARD_PLACEHOLDER.jpg"


export const Scribble = ({
  account,
  web3Modal,
  loadWeb3Modal,
  web3Provider,
  setWeb3Provider,
  logoutOfWeb3Modal,
  txProcessing,
  setTxProcessing,
}) => {
  const isAuthenticated = Boolean(account);
  const userAddress = account;
  const nfTombstoneContract = "0xe3525413c2a15daec57C92234361934f510356b8"; //change to mainnet address
  const spotNFTContract = "0x9455aa2aF62B529E49fBFE9D10d67990C0140AFC";
  const [filter, setFilter] = useState("");
  const [savedImage, setSavedImage] = useState("empty image"); //Saving image for sending to IPFS. This part isn't active yet!
  const contractProcessor = useWeb3ExecuteFunction();
  const nfTombstoneMetaData = nftombstoneData;

  //scribble
  const [contractSelected, setContractSelected] = useState();
  const mindMattersContract = "0xC3C831b19B85FdC2D3E07DE348E7111BE1095Ba1";
  const overloadContract = "0x424F2C77341d692496544197Cc39708F214EEfc4";
  const talesContract = "0x5DF36A4E61800e8cc7e19d6feA2623926C8EF960";
  const peachesAndStrabsContract = "0x8d17f8Ca6EFE4c85981A4C73c5927beEe2Ad1168";
  const abstractContract = "0x8f1e73AA735A33e3E01573665dc7aB66DDFBa4B2";
  const unfinishedContract = "0xeCf0d76AF401E400CBb5C4395C76e771b358FE06";
  const wastelandContract = "0xbc54D075a3b5F10Cc3F1bA69Ee5eDA63d3fB6154";
  const resonateContract = "0xF3544a51b156a3A24a754Cad7d48a901dDbD83d2";

  //for text on canvas
  const [textinput, setTextinput] = useState("");
  const [xInput, setXInput] = useState("160");
  const [yInput, setYInput] = useState("260");
  const [fontSize, setFontSize] = useState("30");
  const [xInputX2, setXInputX2] = useState("163");
  const [yInputX2, setYInputX2] = useState("260");
  const [fontSizeX2, setFontSizeX2] = useState("30");

  const [collection, setCollection] = useState("0xC3C831b19B85FdC2D3E07DE348E7111BE1095Ba1");

  const [textinputText, setTextinputText] = useState("");
  const [xInputText, setXInputText] = useState("198");
  const [yInputText, setYInputText] = useState("287");
  const [fontSizeText, setFontSizeText] = useState("15");
  const [xInputTextX2, setXInputTextX2] = useState("201");
  const [yInputTextX2, setYInputTextX2] = useState("287");
  const [fontSizeTextX2, setFontSizeTextX2] = useState("15");
  const [fontText, setFontText] = useState("Durka");
  const [fontStyleText, setFontStyleText] = useState("normal");

  const [textinputText1, setTextinputText1] = useState("");
  const [xInputText1, setXInputText1] = useState("177");
  const [yInputText1, setYInputText1] = useState("310");
  const [fontSizeText1, setFontSizeText1] = useState("15");
  const [xInputText1X2, setXInputText1X2] = useState("180");
  const [yInputText1X2, setYInputText1X2] = useState("313");
  const [fontSizeText1X2, setFontSizeText1X2] = useState("15");
  const [fontText1, setFontText1] = useState("Durka");
  const [fontStyleText1, setFontStyleText1] = useState("normal");


  //user input text vars

  const textinputUser = (event) => {
    setTextinput(event.target.value);
  };
  const userFontSize = (event) => {
    setFontSize(event.target.value);
  };
  const textinputUserText = (event) => {
    setTextinputText(event.target.value);
  };
  const userFontSizeText = (event) => {
    setFontSizeText(event.target.value);
  };
  const textinputUserText1 = (event) => {
    setTextinputText1(event.target.value);
  };
  const userFontSizeText1 = (event) => {
    setFontSizeText1(event.target.value);
  };

  //name font info
  const collectionOptions = [
    { value: "0xC3C831b19B85FdC2D3E07DE348E7111BE1095Ba1", label: "Mind Matters" },
    { value: "0x424F2C77341d692496544197Cc39708F214EEfc4", label: "Overload" },
    { value: "0x5DF36A4E61800e8cc7e19d6feA2623926C8EF960", label: "Tales" },
    { value: "0x8d17f8Ca6EFE4c85981A4C73c5927beEe2Ad1168", label: "Peaches and Strawbs" },
    { value: "0x8f1e73AA735A33e3E01573665dc7aB66DDFBa4B2", label: "Abstract" },
    { value: "0xeCf0d76AF401E400CBb5C4395C76e771b358FE06", label: "Unfinished" },
    { value: "0xbc54D075a3b5F10Cc3F1bA69Ee5eDA63d3fB6154", label: "Wasteland" },
    { value: "0xF3544a51b156a3A24a754Cad7d48a901dDbD83d2", label: "Resonate" },
  ];
  const [collectionDescription, setCollectionDescription] = useState("Mind matters")

  const handleChange = (selectedOption) => {
    console.log("handleChange", selectedOption.value);
    setCollection(selectedOption.value);
    setCollectionDescription(selectedOption.label);
  };

  /*async function getHasClaimed(tokenURI, id) {
    setTxProcessing(true);
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        if (ENGRAVER_ABI && ENGRAVER_ADDRESS && signer) {
          const contract = new Contract(ENGRAVER_ADDRESS, ENGRAVER_ABI, signer);
          let options = {
            value: ethers.utils.parseEther(".1"),
          };
          console.log(id);
          console.log(tokenURI);

          let tx = await contract.engraveTombstone(id, tokenURI);
          console.log(tx.hash);
          props.setTxProcessing(false);
        }
      }
    } catch (error) {
      console.log(error);
    } finally {
      setTxProcessing(false);
    }
  }
*/
  //For Metadata
  const [tomebstoneBackground, setTombstoneBackground] = useState();
  const [tombstoneBase, setTombstoneBase] = useState();
  const [tombstoneBehind, setTomstoneBehind] = useState();
  const [tombstoneFlair, setTombstoneFlair] = useState();
  const [tombstoneGround, setTombstoneGround] = useState();
  const [tombstoneTop, setTombstoneTop] = useState();
  const [tombstoneId, setTombstoneId] = useState();
  const [name, setName] = useState();
  const [epitaph, setEpitaph] = useState();
  const [epitaph1, setEpitaph1] = useState();

  {
    /* For Image retrieval */
  }
  const [canvasImage, setCanvasImage] = useState({
    TombStone: "",
    Text: "",
  });
  {
    /* For Traits retrieval */
  }
  const [chosenTrait, setChosenTrait] = useState({
    TombStone: "1",
    TombStoneID: "1",
    BackGround: "",
    Base: "",
    Behind: "",
    Flair: "",
    Ground: "",
    Top: "",
    Name: "",
    Epitaph: "",
  });

 
  {
    /* For retrieval of traits */
  }
  const [walletTraits, setWalletTraits] = useState([]);
  const [apiLoaded, setApiLoaded] = useState(false);
  const [checkMyTraits, setCheckMyTraits] = useState(false);
  const [tombstoneSelected, setTombstoneSelected] = useState(false);

//https://api.joepegs.dev/v2/users/{address}/items
//XyVue40t0uzAZRShwfLhTEFSA8piqCRpVIcc

useEffect(() => {
  const getNfts = async () => {
    const options = {
      method: "GET",
      url: `https://api.joepegs.dev/v2/users/${account}/items`,
      params: {
        collectionAddresses: [collection],
      },
      headers: {
        accept: "application/json",
        "x-joepegs-api-key": "XyVue40t0uzAZRShwfLhTEFSA8piqCRpVIcc", //process.env.REACT_APP_MORALIS_API_KEY
      },
    };
    try {
      let response = await axios.request(options);
      console.log(response);
      let data = response.data;
      setWalletTraits(data.result.map((nft) => nft.token_id));
    } catch (error) {
      console.log(error);
    }
  };
  getNfts();
}, [collection]);

  useEffect(() => {
    const getTraits = async () => {
      const options = {
        method: "GET",
        url: `https://deep-index.moralis.io/api/v2/${account}/nft`,
        params: {
          chain: "avalanche",
          format: "decimal",
          token_addresses: collection,
        },
        headers: {
          accept: "application/json",
          "X-API-Key": "dHttwdzMWC7XigAxZtqBpTet7Lih3MqBRzUAIjXne0TIhJzXG4wrpdDUmXPPQFXo", //process.env.REACT_APP_MORALIS_API_KEY
        },
      };
      try {
        let response = await axios.request(options);
        console.log(response);
        let data = response.data;
        setWalletTraits(data.result.map((nft) => nft.token_id));
      } catch (error) {
        console.log(error);
      }
    };
    getTraits();
  }, [collection]);

  function updateCanvasTraits(trait) {
    setCanvasImage((prevImage) => ({
      ...prevImage,
      [trait.traitType]: trait.image,
    }));
    setChosenTrait((prevTrait) => ({
      ...prevTrait,
      [trait.traitType]: trait.traitName,
      [trait.traitType + "ID"]: trait.id,
    }));
    setTombstoneSelected(true);
  }

  function createCard(trait) {
    //Building the card here from Card.jsx passing props and simultaneously fetching traits on click.
    return (
      <div
        key={trait.edition}
        onClick={() => {
          updateCanvasTraits(trait);
        }}
      >
        {" "}
        <Card
          nftName={trait.nftName}
          traitType={trait.traitType}
          traitName={trait.traitName}
          image={trait.image}
          id={trait.id}
        />
      </div>
    );
  }

  // For Searching traits
  const searchText = (event) => {
    setFilter(event.target.value);
  };

  let dataSearch = traits.filter((item) => {
    return Object.keys(item).some((key) =>
      item[key]
        .toString()
        .toLowerCase()
        .includes(filter.toString().toLowerCase())
    );
  });
  let ownedFilter = traits.filter((item) => {
    if (walletTraits.includes(item.id.toString())) {
      return item;
    }
  });

 
  useEffect(() => {
    updateTraitMetaData();
  }, [chosenTrait]);

  function updateTraitMetaData() {
    setTombstoneBackground(
      nftombstoneData[`${chosenTrait.TombStoneID - 1}`].attributes[0].value
    );
    setTomstoneBehind(
      nftombstoneData[`${chosenTrait.TombStoneID - 1}`].attributes[1].value
    );
    setTombstoneBase(
      nftombstoneData[`${chosenTrait.TombStoneID - 1}`].attributes[2].value
    );
    setTombstoneFlair(
      nftombstoneData[`${chosenTrait.TombStoneID - 1}`].attributes[3].value
    );
    setTombstoneTop(
      nftombstoneData[`${chosenTrait.TombStoneID - 1}`].attributes[4].value
    );
    setTombstoneGround(
      nftombstoneData[`${chosenTrait.TombStoneID - 1}`].attributes[5].value
    );
    setTombstoneId(chosenTrait.TombStoneID);
  }


  // Add feature: Filter owned trait cards
  const [ownedCards, setOwnedCards] = useState(true);
  //---------------------------------//

 
  // Main Component Return
  return (
    <div className="container flex-auto mx-auto w-full">
      {/* Canvas Row*/}
      <div className="top-20 grid 2xl:grid-cols-2 xl:grid-cols-2 lg:grid-cols-2 md:grid-cols-1 sm:grid-cols-1 gap-4 mt-1 ml-6 sm:p-5 bg-slate-900 lg:pb-3">
        {/* canvas div */}

        <div
          className="flex p-1 mb-10 sm:mb-10">
          <img src={image1} alt="logo" className="m-0 w-1/2"></img>
          <div className="pb-6 md: pl-10">
            <h1 className="text-center font-mono text-lg text-yellow-400 pt-1 pb-6">
              Scribble Customs
            </h1>
            
        <div className="gap-4 pt-1 pl-2 grid grid-col-4">
          <div className="flex">
            <div className="col-span-2 text-white pr-5">Name: </div>
            <div>
              <input
                type="text"
                className="border-2 border-slate-600 bg-slate-400 text-left font-mono placeholder-slate-600 pl-2 w-24 h-6"
                placeholder="Name"
                value={textinput}
                onChange={textinputUser.bind(this)}
              />
            </div>
          </div>
          <div className="flex">
            <div className="col-span-2 text-white pr-6">Color: </div>
            <div>
              <input
                type="text"
                className="border-2 border-slate-600 bg-slate-400 text-left font-mono placeholder-slate-600 pl-2 w-24 h-6"
                placeholder="Color"
                value={textinputText}
                onChange={textinputUserText.bind(this)}
              />
            </div>


          </div>
          <div className="flex">
            <div className="col-span-2 text-white pr-6">Noun: </div>
            <div>
              <input
                type="text"
                className="border-2 border-slate-600 bg-slate-400 text-left font-mono placeholder-slate-600 pl-2 w-24 h-6"
                placeholder="Noun"
                value={textinputText1}
                onChange={textinputUserText1.bind(this)}
              />
            </div>

            
          </div>
        </div>
          </div>
          
        </div>
        {/* canvas div ends */}
        {/* Stats div*/}
        <div
          className="grow border-dashed border-4 border-slate-500 p-3 pl-5 m-1 text-left col-span-1 w-80 md:mt-10 lg:mt-2 mt-10 sm:mt-10 text-sm"
          style={{ height: "18rem", width: "22rem" }}
        >
          {/* Individual Stats */}
          <div className="font-mono text-white list-none flex pb-3">
            <div
              className={`text-${walletTraits.includes(`${chosenTrait.TombStoneID}`)
                ? "spot-yellow"
                : "[red]"
                } font-bold pr-3 pl-2`}
            >
             {collectionDescription} ID:{" "}
            </div>
            {chosenTrait.TombStoneID}
          </div>

       
          <ScribbleMint
            chosenTrait={chosenTrait}
            walletTraits={walletTraits}
            background={tomebstoneBackground}
            behind={tombstoneBehind}
            flair={tombstoneFlair}
            ground={tombstoneGround}
            tombstone={tombstoneBase}
            top={tombstoneTop}
            id={chosenTrait.TombStoneID}
           // saveImage={saveImage}
            account={account}
            canvas={chosenTrait}
            savedImage={savedImage}
            name={name}
            epitaph={`${epitaph + " " + epitaph1} `}
            txProcessing={txProcessing}
            setTxProcessing={setTxProcessing}
            ownedCards={ownedCards}
            web3Provider={web3Provider}
            tombstoneSelected={tombstoneSelected}
          />
          {/* End of Indiv Stats */}
          {/* Buttons */}
     
          <div className="font-mono text-white list-none flex pb-3 text-sm pl-2 pt-2">
            <div className="text-[red] pr-2 text-xl">* </div>
            NFT has already claimed a custom!
          </div>
          <div className="pr-2">
          <div className="font-mono text-white list-none flex pb-3 text-sm pl-2 pt-2">
            
            Select Collection to use to Claim Custom Token.
          </div><div className="w-full flex">
          <div className="w-full pl-2 pr-2">
              <Select
                options={collectionOptions}
                onChange={handleChange}
                defaultValue={{ label: "Mind Matters", value: "0xC3C831b19B85FdC2D3E07DE348E7111BE1095Ba1" }}
              />
            </div>
          </div></div>



        </div>
      </div>
      {/* Canvas Row Div Ends*/}
      <div className="overflow-y-auto">
        <div className="p-10 grid grid-cols-1 sm:grid-cols-1 md:grid-cols-1 lg:grid-cols-1 xl:grid-cols-6 gap-5 font-mono text-spot-yellow">
          {ownedCards
            ? ownedFilter.map(createCard)
            : dataSearch.map(createCard)}
        </div>
      </div>
      <div className="blade text-slate-900">T</div>
      <div className="bombing text-slate-900">H</div>
      <div className="devil text-slate-900">E</div>
      <div className="drip text-slate-900">S</div>
      <div className="durka text-slate-900">P</div>
      <div className="emm text-slate-900">O</div>
      <div className="eternal text-slate-900">T</div>
      <div className="fresh text-slate-900">2</div>
      <div className="gala text-slate-900">0</div>
      <div className="metal text-slate-900">2</div>
      <div className="predator text-slate-900">2</div>
      <div className="simple text-slate-900">!</div>
    </div>
  );
};
