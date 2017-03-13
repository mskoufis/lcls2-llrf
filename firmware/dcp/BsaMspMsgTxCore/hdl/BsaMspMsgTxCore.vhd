-------------------------------------------------------------------------------
-- File       : BsaMspMsgTxCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-03-13
-- Last update: 2017-03-13
-------------------------------------------------------------------------------
-- Description: GTX7 Wrapper
-------------------------------------------------------------------------------
-- This file is part of 'LCLS2 LLRF Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 LLRF Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;

entity BsaMspMsgTxCore is
   generic (
      TPD_G                 : time       := 1 ns;
      CPLL_REFCLK_SEL_G     : bit_vector := "001";
      SIM_GTRESET_SPEEDUP_G : string     := "FALSE";
      SIMULATION_G          : boolean    := false);
   port (
      -- BSA/MPS Interface
      usrClk        : in  sl;
      usrRst        : in  sl;
      timingStrobe  : in  sl;           -- 1MHz strobe, single cycle
      timeStamp     : in  slv(63 downto 0);
      bsaQuantity0  : in  slv(31 downto 0);
      bsaQuantity1  : in  slv(31 downto 0);
      bsaQuantity2  : in  slv(31 downto 0);
      bsaQuantity3  : in  slv(31 downto 0);
      bsaQuantity4  : in  slv(31 downto 0);
      bsaQuantity5  : in  slv(31 downto 0);
      bsaQuantity6  : in  slv(31 downto 0);
      bsaQuantity7  : in  slv(31 downto 0);
      bsaQuantity8  : in  slv(31 downto 0);
      bsaQuantity9  : in  slv(31 downto 0);
      bsaQuantity10 : in  slv(31 downto 0);
      bsaQuantity11 : in  slv(31 downto 0);
      mpsPermit     : in  slv(3 downto 0);
      -- GTX's Clock and Reset
      cPllRefClk    : in  sl;           -- 185.714 MHz 
      stableClk     : in  sl;           -- GTX's stable clock reference
      stableRst     : in  sl;
      -- GTX Status/Config Interface   
      cPllLock      : out sl;
      txPolarity    : in  sl              := '0';
      txPreCursor   : in  slv(4 downto 0) := (others => '0');
      txPostCursor  : in  slv(4 downto 0) := (others => '0');
      txDiffCtrl    : in  slv(3 downto 0) := "1111";
      -- GTX Ports
      gtTxP         : out sl;
      gtTxN         : out sl;
      gtRxP         : in  sl;
      gtRxN         : in  sl);
end BsaMspMsgTxCore;

architecture mapping of BsaMspMsgTxCore is

   signal txClk      : sl;
   signal txRst      : sl;
   signal axisMaster : AxiStreamMasterType;
   signal axisSlave  : AxiStreamSlaveType;
   signal txData     : slv(15 downto 0);
   signal txdataK    : slv(1 downto 0);

begin

   ---------------------
   -- Data Packer Module
   ---------------------
   U_Packer : entity work.BsaMpsMsgTxPacker
      generic map (
         TPD_G => TPD_G)
      port map (
         -- BSA/MPS Interface
         usrClk        => usrClk,
         usrRst        => usrRst,
         timingStrobe  => timingStrobe,
         timeStamp     => timeStamp,
         bsaQuantity0  => bsaQuantity0,
         bsaQuantity1  => bsaQuantity1,
         bsaQuantity2  => bsaQuantity2,
         bsaQuantity3  => bsaQuantity3,
         bsaQuantity4  => bsaQuantity4,
         bsaQuantity5  => bsaQuantity5,
         bsaQuantity6  => bsaQuantity6,
         bsaQuantity7  => bsaQuantity7,
         bsaQuantity8  => bsaQuantity8,
         bsaQuantity9  => bsaQuantity9,
         bsaQuantity10 => bsaQuantity10,
         bsaQuantity11 => bsaQuantity11,
         mpsPermit     => mpsPermit,
         -- TX Data Interface
         txClk         => txClk,
         txRst         => txRst,
         mAxisMaster   => axisMaster,
         mAxisSlave    => axisSlave);

   ---------------------
   -- Data Framer Module
   ---------------------
   U_Framer : entity work.BsaMpsMsgTxFramer
      generic map (
         TPD_G => TPD_G)
      port map (
         txClk       => txClk,
         txRst       => txRst,
         sAxisMaster => axisMaster,
         sAxisSlave  => axisSlave,
         txData      => txData,
         txdataK     => txdataK);

   -------------
   -- GTX Module
   -------------
   U_Gtx : entity work.BsaMpsMsgTxGtx7
      generic map (
         TPD_G                 => TPD_G,
         CPLL_REFCLK_SEL_G     => CPLL_REFCLK_SEL_G,
         SIM_GTRESET_SPEEDUP_G => SIM_GTRESET_SPEEDUP_G,
         SIMULATION_G          => SIMULATION_G)
      port map (
         -- Clock and Reset
         cPllRefClk   => cPllRefClk,
         stableClk    => stableClk,
         stableRst    => stableRst,
         -- GTX Status/Config Interface   
         cPllLock     => cPllLock,
         txPolarity   => txPolarity,
         txPreCursor  => txPreCursor,
         txPostCursor => txPostCursor,
         txDiffCtrl   => txDiffCtrl,
         -- GTX Interface
         gtTxP        => gtTxP,
         gtTxN        => gtTxN,
         gtRxP        => gtRxP,
         gtRxN        => gtRxN,
         -- TX Interface
         txClk        => txClk,
         txRst        => txRst,
         txData       => txData,
         txDataK      => txDataK);

end architecture mapping;
