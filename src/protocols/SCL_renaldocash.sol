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

//description: A semi-Centralized gas efficient Mixer

enum Renaldo_State
{
    _DEPOSIT,
    _WITHDRAWAL
}


function deposit(){

}

function withdraw(){

}

function acknowledge(){

}

function escape(){

}

function slash(){

}

/* */
function add_blacklist(){

}

/* if a blacklisted member belongs to the withdrawal phase, it is refunded and the state switch back to deposit*/
function cancel_withdrawal(){


}

contract SCL_Renaldo{

    Renaldo_State State;
  


} 