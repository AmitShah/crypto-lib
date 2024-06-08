/********************************************************************************************/
/*
#/*   ╔═╗╔╦╗╔═╗╔═╗╔╦╗╦ ╦  ╔═╗╦═╗╦ ╦╔═╗╔╦╗╔═╗╦  ╦╔╗ 
#/*   ╚═╗║║║║ ║║ ║ ║ ╠═╣  ║  ╠╦╝╚╦╝╠═╝ ║ ║ ║║  ║╠╩╗
#/*   ╚═╝╩ ╩╚═╝╚═╝o╩ ╩ ╩  ╚═╝╩╚═ ╩ ╩   ╩ ╚═╝╩═╝╩╚═╝
#/*              
#/* Copyright (C) 2024 - Renaud Dubois - This file is part of SCL (Smoo.th CryptoLib) project
#/* Description: Testing contract for SCL implementation of rip6565
/********************************************************************************************/
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;


//vectors extracted from https://asecuritysite.com/curve25519/ed
//https://crypto.stackexchange.com/questions/99798/test-vectors-points-for-ed25519
//Point 1G 5866666666666666666666666666666666666666666666666666666666666666 , LSB first
//Point 2G, x= 0x36ab384c9f5a046c3d043b7d1833e7ac080d8e4515d7a45f83c5a14e2843ce0e
//Point 5G x=0x49fda73eade3587bfcef7cf7d12da5de5c2819f93e1be1a591409cc0322ef233


import "forge-std/Test.sol";


import "@solidity/lib/libSCL_rip6565.sol";

import "@solidity/hash/SCL_sha512.sol";


//WIP : current fonctions prove that ed25519 ecc part is correctly implemented, SHA512 need to be integrated for full eddsa
contract SCL_Ed25519Test is Test {


 function test_BaseMul() public view {
  uint256 resX;


  (resX,)=SCL_RIP6565.BasePointMultiply_Edwards(2);
  assertEq(resX, 0x36ab384c9f5a046c3d043b7d1833e7ac080d8e4515d7a45f83c5a14e2843ce0e);//expected 2G result
  
  (resX,)=SCL_RIP6565.BasePointMultiply_Edwards(5);
   assertEq(resX, 0x49fda73eade3587bfcef7cf7d12da5de5c2819f93e1be1a591409cc0322ef233);//expected 5G result
 
 }

 function test_expandSecret()public view {
    uint256 KpubC;
    uint256 expSec;
    //vector 1 from rfc8032
    uint256 secret1=0x4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb;
    uint256 expected1=0x3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c;

    (KpubC,expSec)=SCL_RIP6565.ExpandSecret(secret1);
    assertEq(KpubC, expected1);//expected public key
 
    //vector 3 input secret key, lsb first
    uint256 secret3=0xc5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7;
    //expected public key, lsb fist
    uint256 expected3=0xfc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025;

    (KpubC,expSec)=SCL_RIP6565.ExpandSecret(secret3);
    assertEq(KpubC, expected3);//expected public key       
 }

 function test_hashInternal() public pure{

  uint256 r=0x6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac;
  uint256 KpubC=0xfc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025;
  uint256 expected=0x60ab51a60e3f1ceb60549479b152ae2f4a41d9dd8da0f6c3ef2892d51118e95;//expected internal hash, computed from python reference code
  bytes memory Msg=hex"af82";
  bytes32 high;
  bytes32 low;

  (high, low)=Sha2Ext.sha512(abi.encodePacked(r,KpubC, Msg));
  uint256[2] memory val=[uint256(high), uint256(low)];
  val=SCL_sha512.Swap512(val);
  uint256 red=SCL_RIP6565.Red512Modq(val);
 
  assertEq(SCL_RIP6565.HashInternal(r,KpubC,string(Msg)),expected);
 }

 function test_Fuzz_ed255sqrtmod2(uint256 x) public {
        uint256 val = mulmod(x, x, p);
        uint256 rac = SqrtMod(val);
       
        assertEq(mulmod(rac, rac, p), val);
    }

    function test_rip6565_transformKey() public view{
         uint256[2] memory kPub;
        kPub[0] = 43933056957747458452560886832567536073542840507013052263144963060608791330050;
        kPub[1] = 16962727616734173323702303146057009569815335830970791807500022961899349823996;
        uint256[5] memory extKpub;
        extKpub = SCL_RIP6565.TransformKey(kPub);
        assertEq(extKpub[4],0xfc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025);
    }

    function test_ed255Verif_rfc_BE() public {
        //vector 3 input secret key, page 25 of RFC8032, swapped
        uint256 r=0xacc35adbd780365e443a7484a248e50ca301be3a9ce627480224ecde57d69162;//msb, read as a number
        uint256 s=0xac41eeacebe27c08dd26e71e9157c4a59c64d9860f767ae90f2168d539bff18;//msb, read as a number
        uint256 secret=0xc5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7;//

        bytes memory Msg=hex"af82";
        uint256[5] memory extKpub;
        (extKpub,)=SCL_RIP6565.SetKey(secret);
        
       
        bool res;
        res=SCL_RIP6565.Verify(string(Msg), r, s, extKpub);
        
        assertEq(res,true);
    }


    function test_ed255Verif_rfc_LE() public {
        uint256[5] memory extKpub;
        uint256[2] memory signer;
        
        bool res;

        //vector 2 input , page 25 of RFC8032
       uint256 secret=0x4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb;
       uint256 r=0x92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da;
       uint256 s=0x085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00;
       bytes memory Msg=hex"72";


        (extKpub,signer)=SCL_RIP6565.SetKey(secret);


        res=SCL_RIP6565.Verify_LE(string(Msg), r, s, extKpub); 
        assertEq(res,true);

        //vector 3 input , page 25 of RFC8032
        uint256 r3=0x6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac;//lsb, has to be swapped to be read as a number
        uint256 s3=0x18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a;//lsb, has to be swapped to be read as a number
        
        uint256 secret3=0xc5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7;
        Msg=hex"af82";
       
        (extKpub,signer)=SCL_RIP6565.SetKey(secret3);
    
      
        res=SCL_RIP6565.Verify_LE(string(Msg), r3, s3, extKpub); 
        (r,s)=SCL_RIP6565.SignSlow(secret3, string(Msg));
        assertEq(s,s3); 
        
         //vector 4 input of 1023 bytes, page 25 of RFC8032
        secret=0xf5e5767cf153319517630f226876b86c8160cc583bc013744c6bf255f5cc0ee5;
        r=0x0aab4c900501b3e24d7cdf4663326a3a87df5e4843b2cbdb67cbf6e460fec350;//lsb, has to be swapped to be read as a number
        s=0xaa5371b1508f9f4528ecea23c436d94b5e8fcd4f681e30a6ac00a9704a188a03;//lsb, has to be swapped to be read as a number

        (extKpub,)=SCL_RIP6565.SetKey(secret);

        Msg=hex"08b8b2b733424243760fe426a4b54908632110a66c2f6591eabd3345e3e4eb98fa6e264bf09efe12ee50f8f54e9f77b1e355f6c50544e23fb1433ddf73be84d879de7c0046dc4996d9e773f4bc9efe5738829adb26c81b37c93a1b270b20329d658675fc6ea534e0810a4432826bf58c941efb65d57a338bbd2e26640f89ffbc1a858efcb8550ee3a5e1998bd177e93a7363c344fe6b199ee5d02e82d522c4feba15452f80288a821a579116ec6dad2b3b310da903401aa62100ab5d1a36553e06203b33890cc9b832f79ef80560ccb9a39ce767967ed628c6ad573cb116dbefefd75499da96bd68a8a97b928a8bbc103b6621fcde2beca1231d206be6cd9ec7aff6f6c94fcd7204ed3455c68c83f4a41da4af2b74ef5c53f1d8ac70bdcb7ed185ce81bd84359d44254d95629e9855a94a7c1958d1f8ada5d0532ed8a5aa3fb2d17ba70eb6248e594e1a2297acbbb39d502f1a8c6eb6f1ce22b3de1a1f40cc24554119a831a9aad6079cad88425de6bde1a9187ebb6092cf67bf2b13fd65f27088d78b7e883c8759d2c4f5c65adb7553878ad575f9fad878e80a0c9ba63bcbcc2732e69485bbc9c90bfbd62481d9089beccf80cfe2df16a2cf65bd92dd597b0707e0917af48bbb75fed413d238f5555a7a569d80c3414a8d0859dc65a46128bab27af87a71314f318c782b23ebfe808b82b0ce26401d2e22f04d83d1255dc51addd3b75a2b1ae0784504df543af8969be3ea7082ff7fc9888c144da2af58429ec96031dbcad3dad9af0dcbaaaf268cb8fcffead94f3c7ca495e056a9b47acdb751fb73e666c6c655ade8297297d07ad1ba5e43f1bca32301651339e22904cc8c42f58c30c04aafdb038dda0847dd988dcda6f3bfd15c4b4c4525004aa06eeff8ca61783aacec57fb3d1f92b0fe2fd1a85f6724517b65e614ad6808d6f6ee34dff7310fdc82aebfd904b01e1dc54b2927094b2db68d6f903b68401adebf5a7e08d78ff4ef5d63653a65040cf9bfd4aca7984a74d37145986780fc0b16ac451649de6188a7dbdf191f64b5fc5e2ab47b57f7f7276cd419c17a3ca8e1b939ae49e488acba6b965610b5480109c8b17b80e1b7b750dfc7598d5d5011fd2dcc5600a32ef5b52a1ecc820e308aa342721aac0943bf6686b64b2579376504ccc493d97e6aed3fb0f9cd71a43dd497f01f17c0e2cb3797aa2a2f256656168e6c496afc5fb93246f6b1116398a346f1a641f3b041e989f7914f90cc2c7fff357876e506b50d334ba77c225bc307ba537152f3f1610e4eafe595f6d9d90d11faa933a15ef1369546868a7f3a45a96768d40fd9d03412c091c6315cf4fde7cb68606937380db2eaaa707b4c4185c32eddcdd306705e4dc1ffc872eeee475a64dfac86aba41c0618983f8741c5ef68d3a101e8a3b8cac60c905c15fc910840b94c00a0b9d0";
        res=SCL_RIP6565.Verify_LE(string(Msg), r, s, extKpub); 
      
        assertEq(res,true);
    }


 /*assess all testvectors of  [ED25519-TEST-VECTORS]
              Bernstein, D., Duif, N., Lange, T., Schwabe, P., and B.
              Yang, "Ed25519 test vectors", July 2011,
              <http://ed25519.cr.yp.to/python/sign.input>.*/
 function test_rip6565_allrfc() public view {
     uint256[5] memory extKpub;
     uint256[2] memory signer;

        bool res;
 
        string memory file = "./test/utils/ed25519tv.json";
        while (true) {
           
            string memory vector = vm.readLine(file);
            if (bytes(vector).length == 0) {
                break;
            }
            
            uint256 secret=uint256(stdJson.readBytes32(vector,".secret"));
            uint256 r = uint256(stdJson.readBytes32(vector,".r"));
            uint256 s = uint256(stdJson.readBytes32(vector,".s"));
            bytes memory Msg=stdJson.readBytes(vector,".msg");
            uint256 r2;
            uint256 s2;
            (extKpub,signer)=SCL_RIP6565.SetKey(secret);
            res=SCL_RIP6565.Verify_LE(string(Msg), r, s, extKpub); 
            (r2,s2)=SCL_RIP6565.SignSlow(secret, string(Msg));
            assertEq(s,s2); 

            assertEq(res,true);
        }

    }

}