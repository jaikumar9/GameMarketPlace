import React from "react";
import { Routes, Route } from "react-router-dom";
import "./App.css";
import Swap from "./component/Swap";
import HeroSections from "./component/HeroSections";
import Token from "./component/Token";

function App() {
  return (
    <>
      <Routes>
        <Route path="/" element={<HeroSections />} />
        <Route path="/swap" element={<Swap />} />
        <Route path="/token" element={<Token />} />
      </Routes>
    </>
  );
}

export default App;
