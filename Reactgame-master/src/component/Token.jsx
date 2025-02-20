import React, { useEffect, useState } from "react";
import Navbar from "./Navbar";
import Footer from "./Footer";

function Token() {
  const boxes = Array.from({ length: 100 }, (_, i) => i + 1);
  const [clickedBox, setClickedBox] = useState(null);
  const [randomCount, setRandomCount] = useState(null);
  const [openPopup, setOpenPopup] = useState(null); // Track which popup is open

  // Function to toggle a specific popup
  const togglePopup = (popupId, event) => {
    event.stopPropagation(); // Prevent body click from immediately closing the popup
    setOpenPopup((prev) => (prev === popupId ? null : popupId)); // Toggle the specific popup
  };

  // Close all popups when clicking outside
  const handleBodyClick = () => {
    setOpenPopup(null);
  };
  useEffect(() => {
    // Attach event listener to the document body
    document.body.addEventListener("click", handleBodyClick);

    // Cleanup event listener on unmount
    return () => {
      document.body.removeEventListener("click", handleBodyClick);
    };
  }, []);

  // Function to handle the box click and generate a random count
  const handleBoxClick = (box) => {
    if (clickedBox === null) {
      const randomCount = Math.floor(Math.random() * 100) + 1;
      setClickedBox(box);
      setRandomCount(randomCount);
    }
  };

  return (
    <>
      <div className="backsideImage">
        <Navbar />
        <div className="container">
          <div className="d-flex align-items-center justify-content-between mt-5">
            <div>
              <div
                className="balncBx px-3 py-2 rounded"
                onClick={(e) => togglePopup("popup1", e)}
              >
                Balance: <span className="text-white ms-2">25.0</span>
              </div>
              {openPopup === "popup1" && (
                <div className="popup-box p-3 rounded">
                  <div className="popup-box-inner">
                    <p className="text-white text-center fs-2 fw-medium">
                      Better Luck <br /> Next Time!
                    </p>
                  </div>
                </div>
              )}
            </div>
            <div>
              <h2
                className="fs-3 text-white mb-0"
                onClick={(e) => togglePopup("popup2", e)}
              >
                Game
              </h2>
              {openPopup === "popup2" && (
                <div className="popup-box p-3 rounded">
                  <div className="popup-box-inner">
                    <p className="text-white text-center fs-2 fw-medium">
                      Congratulations! <br /> You are the Winner.
                    </p>
                  </div>
                </div>
              )}
            </div>
            <p className="fs-6 text-white-50 mb-0">Find way to win</p>
          </div>
          <div className="mt-5">
            <div className="nwBox">
              <div className="rounded mines-box">
                {boxes.map((box) => (
                  <div
                    key={box}
                    className="text-white box-game"
                    onClick={() => handleBoxClick(box)}
                    style={{
                      cursor:
                        clickedBox === null || clickedBox === box
                          ? "pointer"
                          : "not-allowed",
                      opacity:
                        clickedBox !== null && clickedBox !== box ? 0.5 : 1,
                    }}
                  >
                    {/* Show the random count if the box has been clicked */}
                    {clickedBox === box && randomCount}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
        <Footer />
      </div>
    </>
  );
}

export default Token;
