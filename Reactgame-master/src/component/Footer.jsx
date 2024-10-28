import React from "react";
import { LuSend } from "react-icons/lu";
import { FaTwitter } from "react-icons/fa";


function Footer() {
  return (
    <>
      <div className="container mt-5">
        <div className="row">
          <div className="col-md-12">
            <div className="d-flex justify-content-between">
              <div className="text-white fw-bold">Logo</div>
              <div>
                <hr />
              </div>
             <div className="d-flex gap-3">
             <div><span className="text-white">  Follow Us</span> <FaTwitter  size={30} className="bg-white rounded-circle p-1 ms-2" />
             </div>

             <div> <LuSend size={30} className="rounded-circle bg-white px-1  "/></div>

             </div>
            </div>
            <div className="text-white text-center">
             <p>Lorem ipsum - Copyright  ©  2024, All rights reserved</p>
             </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default Footer;
