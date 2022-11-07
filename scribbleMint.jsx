import { stringify } from "postcss";
import React, { useEffect, useState } from "react";
import { useWeb3ExecuteFunction, useMoralisCloudFunction } from "react-moralis";
import spotNFTAbi from "../contracts/spotNFTAbi.json";
import Moralis from "moralis";
import unnamedData from "../metadata";
import unnamedAbi from "../contracts/spotNFTAbi.json";
import nfTombstoneABI from "../contracts/nfTombstoneABI.json";
import axios from "axios";
import { ethers, Contract } from "ethers";
import {
  TOMBSTONE_ADDRESS,
  TOMBSTONE_ABI,
} from "./Contracts/TombstoneContract";
import { ENGRAVER_ABI, ENGRAVER_ADDRESS } from "./Contracts/EngraverContract";

export default function ScribbleMint({
  props,
  chosenTrait,
  walletTraits,
  background,
  behind,
  flair,
  ground,
  tombstone,
  top,
  id,
  saveImage,
  account,
  canvas,
  savedImage,
  name,
  epitaph,
  txProcessing,
  setTxProcessing,
  ownedCards,
  web3Provider,
  tombstoneSelected,
}) {
  const {
    data: mintData,
    error: mintError,
    fetch: mintFetch,
    isFetching: mintFetching,
    isLoading: mintLoading,
  } = useWeb3ExecuteFunction();

  function checkTraits() {
    // let isSafeBG = props.solidBG.some(
    //   (ai) => props.chosenTrait.BackgroundID === ai
    // );
    if (
      walletTraits.includes(String(chosenTrait.BackgroundID)) &&
      walletTraits.includes(String(chosenTrait.BodyID)) &&
      walletTraits.includes(String(chosenTrait.HeadID)) &&
      walletTraits.includes(String(chosenTrait.MouthID)) &&
      walletTraits.includes(String(chosenTrait.EyesID)) &&
      (walletTraits.includes(String(chosenTrait.HeadwearID)) ||
        chosenTrait.HeadwearID === "599")
    ) {
      return true;
    } else return false;
  }

  async function uploadToMoralis(filename, contents) {
    const options = {
      method: "POST",
      url: "https://deep-index.moralis.io/api/v2/ipfs/uploadFolder",
      headers: {
        accept: "application/json",
        "content-type": "application/json",
        "X-API-Key": process.env.REACT_APP_MORALIS_API_KEY,
      },
      data: [{ path: filename, content: contents }],
    };

    let response = await axios.request(options);
    return response;
  }

  async function setTokenURI(tokenURI, id) {
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
          alert(
            "Engraved! Refresh your metadata on Campfire, Kalao or Joepegs!"
          );
        }
      }
    } catch (error) {
      console.log(error);
    } finally {
      setTxProcessing(false);
    }
  }

  async function engraveTombstone() {
    setTxProcessing(true);
    try {
      let signature = await web3Provider
        .getSigner()
        .signMessage(
          `Allow The Spot to process metadata upload and token URI setting for token ${id}`
        );
      const base64ImgContents = await saveImage();
      let imgResponse = await uploadToMoralis(
        `${id}-img.png`,
        base64ImgContents
      );

      let imgURL = imgResponse.data.length > 0 ? imgResponse.data[0].path : "";

      const metadata = {
        name: "NFTombstone",
        description: "Engraved NFTombstone",
        image: imgURL,
        edition: id,
        attributes: [
          {
            trait_type: "Background:",
            value: background,
          },
          {
            trait_type: "Behind",
            value: behind,
          },
          {
            trait_type: "Flair",
            value: flair,
          },
          {
            trait_type: "Ground",
            value: ground,
          },
          {
            trait_type: "Tombstone",
            value: tombstone,
          },
          {
            trait_type: "Top",
            value: top,
          },
          {
            trait_type: "Name",
            value: name,
          },
          {
            trait_type: "Epitaph",
            value: epitaph,
          },
        ],
      };

      let jsonResponse = await uploadToMoralis(`${id}-json.json`, metadata);

      let jsonURL =
        jsonResponse.data.length > 0 ? jsonResponse.data[0].path : "";

      await setTokenURI(jsonURL, id);
    } catch (error) {
      console.log(error);
    } finally {
      setTxProcessing(false);
    }
  }

  if (txProcessing) {
    return (
      <div>
        <button
          className="inline-flex m-1 rounded-lg px-4 py-2 border-2 border-spot-yellow text-spot-yellow
     duration-300 font-mono font-bold text-base"
          disabled
        >
          <svg className="inline animate-ping h-5 w-5 mr-3" viewBox="0 0 35 35">
            <circle
              className="path"
              cx="12"
              cy="15"
              r="10"
              fill="yellow"
              stroke="yellow"
              strokeWidth="2"
            ></circle>
          </svg>
          Processing...
        </button>
      </div>
    );
  } else
    return (
      <div className="flex w-full">
        <div className="w-full pr-5 pl-1">
          <button
            className="m-1 w-full rounded-lg px-1 py-1 border-2 border-gray-200 text-gray-200
     hover:bg-gray-200 hover:text-gray-900 duration-300 font-mono font-bold text-base disabled:border-gray-600 disabled:hover:bg-gray-900 disabled:text-gray-600 disabled:hover:text-gray-600"
            disabled={!ownedCards || !tombstoneSelected}
            onClick={() => engraveTombstone()}
          >
            Mint Custom Card
          </button>
        </div>
      </div>
    );
}
