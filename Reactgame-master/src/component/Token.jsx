import React from "react";
import Navbar from "./Navbar";
import Footer from "./Footer";
// import Butons from "./Butons";

function Token() {
  const boxes = Array.from({ length: 100 }, (_, i) => i + 1);

  return (
    <>
      <div className="backsideImage">
        <Navbar />
        <div className="container">
          <div className="row gap-4 justify-content-center">
            {/* Left Section - Mines Box */}
            <div className="col-md-3 rounded mines-box">
              <div className="text-white">
                <h6>Mines</h6>
                <p style={{ color: "#867F85" }}>
                  Find gems on field and avoid mines
                </p>
              </div>

              {/* Wager Input */}
              <div className="form-group">
                <label
                  htmlFor="inputBox"
                  className="form-label"
                  style={{ color: "#867F85" }}
                >
                  Wager
                </label>
                <input
                  type="text"
                  id="buyInput"
                  className="form-control border-0"
                  style={{
                    backgroundColor: "#251A23",
                    color: "white",
                    padding: "5px",
                    borderRadius: "4px",
                  }}
                />
              </div>

              {/* Additional Input Boxes */}
              <div className="row mt-3">
                <div className="col-md-3 col-sm-6 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0 text-center"
                    placeholder="MIN"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-3 col-sm-6 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0 text-center"
                    placeholder="1/2"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-3 col-sm-6 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0 text-center"
                    placeholder="*2"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-3 col-sm-6 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0 text-center"
                    placeholder="MAX"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
              </div>

              <div className="mt-3" style={{ color: "#867F85" }}>
                <h6>Mines number (1-24)</h6>
              </div>

              {/* Additional Input Boxes */}
              <div className="row mt-4">
                <div className="col-md-4 col-sm-12 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0"
                    placeholder="|"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-2 col-sm-3 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0 text-center"
                    placeholder="3"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-2 col-sm-3 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0 text-center"
                    placeholder="5"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-2 col-sm-3 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0 text-center"
                    placeholder="10"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-2 col-sm-3 mb-2">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0 text-center"
                    placeholder="20"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
              </div>

              <div className="row mt-3 gap-3">
                <div className="col-md-6">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0"
                    placeholder="Mines"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "2px 2px 60px 2px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-5">
                  <input
                    type="text"
                    className="form-control custom-placeholder border-0"
                    placeholder="Gems"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "2px 2px 60px 2px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
              </div>

              <div className="form-group mt-2">
                <label
                  htmlFor="inputBox"
                  className="form-label"
                  style={{ color: "#867F85" }}
                >
                  Multiple bets(1-100)
                </label>
                <input
                  type="text"
                  id="buyInput"
                  placeholder="|"
                  className="form-control border-0"
                  style={{
                    backgroundColor: "#251A23",
                    color: "white",
                    padding: "5px",
                    borderRadius: "4px",
                  }}
                />
              </div>

              <div className="row mt-2">
                <div className="col-md-6">
                  <label
                    htmlFor="inputBox"
                    className="form-label"
                    style={{ color: "#867F85" }}
                  >
                    Max payout
                  </label>
                  <input
                    type="text"
                    id="buyInput"
                    placeholder="|"
                    className="form-control border-0"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
                <div className="col-md-6">
                  <label
                    htmlFor="inputBox"
                    className="form-label"
                    style={{ color: "#867F85" }}
                  >
                    Total Wager
                  </label>
                  <input
                    type="text"
                    id="buyInput"
                    placeholder="|"
                    className="form-control border-0"
                    style={{
                      backgroundColor: "#251A23",
                      color: "white",
                      padding: "5px",
                      borderRadius: "4px",
                    }}
                  />
                </div>
              </div>

              <div className="start-game-btn text-center mt-3">
                <button>Start Game</button>
              </div>
            </div>

            {/* Right Section */}
            <div className="col-md-5 rounded mines-box gap-3 d-flex flex-wrap">
              {boxes.map((box) => (
                <div
                  key={box}
                  className="col text-white box-game"
                  style={{ width: "10%" }}
                >
                  {box < 10 ? `0${box}` : box}
                  {/* Add leading zero for numbers < 10 */}
                </div>
              ))}

              {/* <Butons /> */}
            </div>
          </div>
        </div>
        <Footer />
      </div>
    </>
  );
}

export default Token;
