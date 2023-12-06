/********************************************************************************************/
/*
/*     ___                _   _       ___               _         _    _ _    
/*    / __|_ __  ___  ___| |_| |_    / __|_ _ _  _ _ __| |_ ___  | |  (_) |__ 
/*    \__ \ '  \/ _ \/ _ \  _| ' \  | (__| '_| || | '_ \  _/ _ \ | |__| | '_ \
/*   |___/_|_|_\___/\___/\__|_||_|  \___|_|  \_, | .__/\__\___/ |____|_|_.__/
/*                                         |__/|_|           
/*              
/* Copyright (C) 2023 - Renaud Dubois - This file is part of SCL (Smooth CryptoLib) project
/* License: This software is licensed under MIT License                                        
/********************************************************************************************/
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;


import "forge-std/Test.sol";

import { p, gx, gy,n } from "@solidity/fields/SCL_babyjujub.sol";
import {ec_Normalize, ec_Add, ec_Scaling, ec_Unscaling, ecAff_isOnCurve, ec_mulmuladdX} from "@solidity/elliptic/SCL_am1ted.sol";


//vectors are extracted from
//https://github.com/iden3/circomlibjs/blob/4f094c5be05c1f0210924a3ab204d8fd8da69f49/test/babyjub.js
//https://github.com/iden3/circomlibjs/blob/4f094c5be05c1f0210924a3ab204d8fd8da69f49/src/babyjub.js
//assuming a non reduced Twisted edwards form


contract SCL_babyjjTest is Test {


function test_Scaling() public
{
  console.log("gx=", gx);
  uint256 unscaled_gx=5299619240641551281634865583518297030282874472190772894086521144482721001553;
  uint256 resX;
  (resX,)= ec_Scaling(unscaled_gx, gy);
  
  bool res=ecAff_isOnCurve(gx,gy);
   assertEq(res,true);
  assertEq(resX, gx);
  (resX,)= ec_Unscaling(resX, gy);
  assertEq(resX, unscaled_gx);
}

function test_Add() public 
{
    uint256 resX;
    uint256 resY;
    uint256 z;
    uint256 t;

    console.log("           * ec_add:");
    uint256 x1=17777552123799933955779906779655732241715742912184938656739573121738514868268;
    uint256 y1=2626589144620713026669568689430873010625803728049924121243784502389097019475;
    (x1, y1)=ec_Scaling(x1, y1);
    

    bool res=ecAff_isOnCurve(x1,y1);
    assertEq(res,true);

    //result of Doubling x1 (unreduced representation)
    uint256 dblX=6890855772600357754907169075114257697580319025794532037257385534741338397365;
    uint256 dblY=4338620300185947561074059802482547481416142213883829469920100239455078257889;
    (dblX, dblY)=ec_Scaling(dblX, dblY);
    res=ecAff_isOnCurve(dblX, dblY);
    assertEq(res,true);
   
    (resX, resY, z, t)=ec_Add(x1, y1, 1, mulmod(x1,y1,p) , x1, y1, 1, mulmod(x1,y1,p));
    (resX, resY)=ec_Normalize(resX, resY,z,t );
    res=ecAff_isOnCurve(resX, resY);
    assertEq(res,true);

    console.log("                             OK");


    //uint256 x2=16540640123574156134436876038791482806971768689494387082833631921987005038935;
    //uint256 y2=20819045374670962167435360035096875258406992893633759881276124905556507972311;
    

}

function test_mulmuladd() public {

  console.log("           * ec_mulmuladdX:");

  uint256 resX=ec_mulmuladdX(0,0, n+1, 0);
  assertEq(resX, gx);
  
  console.log("                             OK");
}


 function test_babyjj() public {
    test_Scaling();
    test_Add();
    test_mulmuladd();
 }

}