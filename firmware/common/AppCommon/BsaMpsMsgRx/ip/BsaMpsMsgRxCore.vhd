-------------------------------------------------------------------------------
-- File       : BsaMpsMsgRxCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-03-13
-- Last update: 2017-04-05
-------------------------------------------------------------------------------
-- Description: RX Data Framer
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.BsaMpsMsgRxFramerPkg.all;

entity BsaMpsMsgRxCore is
   generic (
      TPD_G            : time            := 1 ns;
      SIMULATION_G     : boolean         := false;
      AXI_CLK_FREQ_G   : real            := 156.25E+6;  -- units of Hz
      AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_DECERR_C);
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- RX Frame Interface (axilClk domain)     
      remoteRd        : in  sl;
      remoteValid     : out sl;
      remoteMsg       : out MsgType;
      -- EMU TX Data Interface (txClk domain)
      txClk           : out sl;
      txRst           : out sl;
      txData          : in  slv(15 downto 0) := (others => '0');
      txDataK         : in  slv(1 downto 0)  := (others => '0');
      -- Remote LLRF BSA/MPS Ports
      gtRefClk        : in  sl;
      gtRxP           : in  sl;
      gtRxN           : in  sl;
      gtTxP           : out sl;
      gtTxN           : out sl);
end BsaMpsMsgRxCore;

architecture mapping of BsaMpsMsgRxCore is

   signal rxClk       : sl               := '0';
   signal rxRst       : sl               := '0';
   signal rxValid     : sl               := '0';
   signal rxData      : slv(15 downto 0) := (others => '0');
   signal rxdataK     : slv(1 downto 0)  := (others => '0');
   signal rxDecErr    : slv(1 downto 0)  := (others => '0');
   signal rxDispErr   : slv(1 downto 0)  := (others => '0');
   signal rxBufStatus : slv(2 downto 0)  := (others => '0');
   signal rxPolarity  : sl               := '0';
   signal txPolarity  : sl               := '0';
   signal loopback    : sl               := '0';
   signal cPllLock    : sl               := '0';
   signal gtRst       : sl               := '0';

begin

   U_Gth : entity work.BsaMpsGthCoreWrapper
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G)
      port map (
         -- RX Data Interface (rxClk domain)
         rxClk       => rxClk,
         rxRst       => rxRst,
         rxValid     => rxValid,
         rxData      => rxData,
         rxdataK     => rxdataK,
         rxDecErr    => rxDecErr,
         rxDispErr   => rxDispErr,
         rxBufStatus => rxBufStatus,
         rxPolarity  => rxPolarity,
         txPolarity  => txPolarity,
         loopback    => loopback,
         cPllLock    => cPllLock,
         gtRst       => gtRst,
         -- EMU TX Data Interface (txClk domain)
         txClk       => txClk,
         txRst       => txRst,
         txData      => txData,
         txDataK     => txDataK,
         -- Remote LLRF BSA/MPS Ports
         gtRefClk    => gtRefClk,
         stableClk   => axilClk,
         gtRxP       => gtRxP,
         gtRxN       => gtRxN,
         gtTxP       => gtTxP,
         gtTxN       => gtTxN);

   U_RxFramer : entity work.BsaMpsMsgRxFramer
      generic map (
         TPD_G            => TPD_G,
         SIMULATION_G     => SIMULATION_G,
         AXI_CLK_FREQ_G   => AXI_CLK_FREQ_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- RX Data Interface (rxClk domain)
         rxClk           => rxClk,
         rxRst           => rxRst,
         rxValid         => rxValid,
         rxData          => rxData,
         rxdataK         => rxdataK,
         rxDecErr        => rxDecErr,
         rxDispErr       => rxDispErr,
         rxBufStatus     => rxBufStatus,
         rxPolarity      => rxPolarity,
         txPolarity      => txPolarity,
         loopback        => loopback,
         cPllLock        => cPllLock,
         gtRst           => gtRst,
         -- RX Frame Interface (axilClk domain)     
         remoteRd        => remoteRd,
         remoteValid     => remoteValid,
         remoteMsg       => remoteMsg);

end mapping;
