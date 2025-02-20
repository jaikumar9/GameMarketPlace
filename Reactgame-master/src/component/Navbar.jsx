import React, { useState } from "react";
import { TbBrandNetbeans } from "react-icons/tb";
import { Link } from "react-router-dom";

function Navbar() {
  const [isCollapsed, setIsCollapsed] = useState(true);

  const toggleNavbar = () => {
    setIsCollapsed(!isCollapsed);
  };

  return (
    <div className="container">
      <nav className="navbar navbar-expand-lg navbar-light bg-transparent justify-content-between">
        {/* Logo */}
        <div className="d-flex align-items-center justify-content-between leftSection">
          <Link className="navbar-brand text-white" to="/">
            logo
          </Link>

          {/* Toggle button for mobile view */}
          <button
            className="navbar-toggler bg-white"
            type="button"
            onClick={toggleNavbar}
            aria-controls="navbarNav"
            aria-expanded={!isCollapsed}
            aria-label="Toggle navigation"
          >
            <span className="navbar-toggler-icon"></span>
          </button>
        </div>
        <div className="rightSection">
          {/* Collapsible Navbar */}
          <div
            className={`collapse navbar-collapse ${!isCollapsed ? "show" : ""}`}
            id="navbarNav"
          >
            <ul className="navbar-nav mx-auto gap-lg-5 px-4 d-flex justify-content-center navMidSec">
              <li className="nav-item active">
                <Link className="nav-link text-white" to="/swap">
                  Swap
                </Link>
              </li>
              <li className="nav-item">
                <Link className="nav-link text-white" to="/token">
                  Tokens
                </Link>
              </li>
              <li className="nav-item">
                <a className="nav-link text-white" href="/">
                  NET
                </a>
              </li>
            </ul>
          </div>

          {/* Wallet connection and icon - shown/hidden on mobile */}
          <div
            className={`d-flex align-items-center ${
              !isCollapsed ? "d-flex" : "d-none"
            } d-lg-flex`}
          >
            <ul className="navbar-nav d-flex gap-3 p-3 m-md">
              <li className="circle-img border rounded-pill d-flex align-items-center justify-content-center">
                <TbBrandNetbeans style={{ color: "#FC2F77" }} size={25} />
              </li>
              <li>
                <w3m-button />
              </li>
            </ul>
          </div>
        </div>
      </nav>
    </div>
  );
}

export default Navbar;
