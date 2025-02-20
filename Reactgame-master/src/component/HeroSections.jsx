import React from "react";
import { RiArrowRightUpLine } from "react-icons/ri";
import Navbar from "./Navbar";
import Footer from "./Footer";

export default function HeroSections() {
  return (
    <div className="backsideImage">
      <Navbar />
      <div className="container">
        <div className="">
          <div className="p-5 mt-5 d-flex justify-content-center text-center">
            <div className="heading-container">
              <div className="heading text-white">
                <h1>To Generate A New</h1>
              </div>
              <div className="heading text-white background-image">
                <h1>Game</h1>
              </div>
            </div>
          </div>
          <div className="text-white d-flex justify-content-center text-center mt-5">
            <p>Lorem ipsum dolor sit amet consectetuer adipiscing elit.</p>
          </div>
          <div className="getstart-btn d-flex justify-content-center">
            <button className="text-white">
              Launch App <RiArrowRightUpLine />
            </button>
          </div>
        </div>
      </div>
      <div className="">{/* <Footer /> */}</div>
    </div>
  );
}
