/*
 Esc3cdump.java - create commands for an Epson Stylus Color 300 printer

    Copyright Glenn Ramsey 2000

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

This program creates commands to send to the Epson Stylus Color 300 printer.

I wrote it so that I could see how the data sent to the printer maps
to the way the ink is put onto the page. Further information about the
printer is available (at the time of writing - 8/4/2000) from 
http://homepages.ihug.co.nz/~Sglennr.

If you know the ESC P/2 language then it should make some sense. There is an
explanation of how the NozzleCmd class works in its comment.
*/

class Esc3cdump
{
   
   public static void main( String arg[] ) throws java.io.IOException {
      Esc300 prn;
      Esc3cdump esc = new Esc3cdump();
      prn = esc. new Esc300();
      prn.reset();
      prn.reset();
      prn.direction(0);// bidirectional
      prn.graphicsmode(1);
      prn.resolution(360);
      prn.moveyrel(600);
      prn.colour('K');
      //prn.nozzles("1101001101001101001101001101001101001101001101001101001101001101", 1080);
      prn.nozzles("0010110010110010110010110010110010110010110010110010110010110010", 360);
      prn.moveyrel(31); 
      prn.nozzles("0010110010110010110010110010110010110010110010110010110010110010", 360);
      prn.moveyrel(31); 
      prn.nozzles("0010110010110010110010110010110010110010110010110010110010110010", 360);  
      prn.endofjob();
      prn.reset();
      prn.reset();
   }

   class Esc300 {
       void colour(char col) throws java.io.IOException {
	   ColourCmd cmd = new ColourCmd(col); 
       }

       void nozzles(String s, int numbits) throws java.io.IOException {
	   NozzleCmd cmd = new NozzleCmd(s,numbits);
       }

       void reset()throws java.io.IOException {
	   ResetCmd cmd = new ResetCmd();
       }

       void direction(int mode)throws java.io.IOException {
	   DirectionCmd cmd = new DirectionCmd(mode);
       }

       void resolution(int res)throws java.io.IOException {
	   ResolutionCmd cmd = new ResolutionCmd(res);
       }

       void graphicsmode(int mode)throws java.io.IOException {
	   GraphicsmodeCmd cmd = new GraphicsmodeCmd(mode);
       }

       void  moveyrel(int distance)throws java.io.IOException {
	   MoveYRelCmd cmd = new MoveYRelCmd(distance);
       }

       void  endofjob() throws java.io.IOException {
	   EndOfJobCmd cmd = new EndOfJobCmd();
       }
   }
   
   class Esc300Cmd {
       protected byte[] _cmd;

       protected void _send() throws java.io.IOException {
	   System.out.write(_cmd); 
       }
   }

   class ColourCmd extends Esc300Cmd {
       public ColourCmd(char col) throws java.io.IOException {
	   _cmd = new byte[4];
	   byte icomp;

	   switch(col){
	       case 'K':
		   icomp=0;
	       break;
	       case 'C':
		   icomp=1;
	       break;
	       case 'M':
		   icomp=2;
	       break;
	       case 'Y':
		   icomp=3;
	       break;
	       default:
		   System.err.println(col + " is not a valid colour, using K instead.");
		   icomp=0;
		   col='K';
	   }
	   _cmd[0] = 0x1b;	// ESC
	   _cmd[1] = 0x72;	// r
	   _cmd[2] = icomp; // The selection
	   _cmd[3] = (byte)'\r';	// carriage return

	   _send();

	   System.err.println("Set color " + col + ".");
       }
   }

   class DirectionCmd extends Esc300Cmd {
	public DirectionCmd(int mode) throws java.io.IOException {
	   _cmd = new byte[3];

	   _cmd[0] = 0x1b;	// ESC
	   _cmd[1] = (byte)'U';	
	   _cmd[2] = (byte)mode;
	   _send();
	   System.err.println("Set "+ (1==mode ? "unidirectional" : "bidirectional"));
       }

   }

   class GraphicsmodeCmd extends Esc300Cmd {
	public GraphicsmodeCmd(int mode) throws java.io.IOException {
	   _cmd = new byte[6];

	   _cmd[0] = 0x1b;	// ESC
	   _cmd[1] = (byte)'(';	
	   _cmd[2] = (byte)'G';
	   _cmd[3] = 1;
	   _cmd[4] = 0;
	   _cmd[5] = (byte)mode;
	   _send();
	   System.err.println("Set Graphicsmode "+ mode);
       }
   }

   class MoveYRelCmd extends Esc300Cmd {
	public MoveYRelCmd(int distance) throws java.io.IOException {
	   _cmd = new byte[7];
	   int ml,mh;

	   mh=(distance/256);
	   ml=(distance%256);

	   _cmd[0] = 0x1b;	// ESC
	   _cmd[1] = (byte)'(';	//
	   _cmd[2] = (byte)'v';
	   _cmd[3] = 2;
	   _cmd[4] = 0;
	   _cmd[5] = (byte)ml;
	   _cmd[6] = (byte)mh;
	   _send();
	   System.err.println("Move Y relative "+((mh*256)+ml));
       }
   }
   
   /**
   The printer has 64 nozzles which, unlike 'proper' ESC P/2 printers are explicitly
   mapped to 'rows' in the data. So for each pass of the head 64 rows of data are
   required.
   
   Parameters:
   String rows - a string that indicates which nozzles to fire. A '0' character
   indicates to not fire the nozzle, any other character indicates to fire it.
   If the string is <64 chars long then the undefined rows are assumed to be '0'.
   
   int numbits - the number of bits to wriite in each row, controls the length of the
   line drawn on the page. A value of 360 would print a pass 1 inch long.
   */
   
   class NozzleCmd extends Esc300Cmd {

      public NozzleCmd (String rows, int numbits) throws java.io.IOException {
	 _cmd = new byte[8];
	 int i;
	 if (numbits > 2880) numbits=2880; // 8 inches max
	 byte nl = (byte)(numbits%256);  // number of bits per row low byte
	 byte nh = (byte)(numbits/256);   // number of bits per row high byte
	 byte v=10;     // x res 3600/10 = 360 dpi 
	 byte h=10;     // y res 3600/10 = 360 dpi
	 byte m=64;     // max number of bytes of data in 'rows' 
	 int k = (int)m*(int)(((nh*256)+nl+7)/8); // Number of bytes we are sending and the printer is expecting
	 _cmd[0] = 0x1b;	// ESC
	 _cmd[1] = (byte)'.';
	 _cmd[2] = 0;      // not run length encoded
	 _cmd[3] = v;      
	 _cmd[4] = h;      
	 _cmd[5] = m; 
	 _cmd[6] = nl;
	 _cmd[7] = nh;
	 _send();

	 _cmd = new byte[k/m];

	 for ( i=0 ; (i < rows.length()) && (i < m) ; i++){ 
	    for (int j=0 ; j < k/m  ; j++ ) {
	       if (rows.charAt(i)=='0') {
	          _cmd[j]=0;
	       } else {
	          _cmd[j]=(byte)0x78;
	       }
	    }         
	    _send();
	 }
	 for ( ; i < m ; i++ ) {
	    for (int j=0 ; j < k/m ; j++ ) {
	          _cmd[j]=0;
	    }
	    _send();
	 }

	 _cmd = new byte[1];
	 _cmd[0] = (byte)0x0d; // cr
	 //_cmd[1] = (byte)0x0a;
	 _send();
	 System.err.println("Raster data "+3600/v+" "+3600/h+" "+m+" "+8*k/m+" "+rows);
       }
   }

   class ResetCmd extends Esc300Cmd {
	public ResetCmd() throws java.io.IOException {
	   _cmd = new byte[2];

	   _cmd[0] = 0x1b;	// ESC
	   _cmd[1] = 0x40;	// @
	   _send();
	   System.err.println("Reset.");
       }

   }

   class ResolutionCmd extends Esc300Cmd {
	public ResolutionCmd(int res) throws java.io.IOException {
	   _cmd = new byte[6];

	   _cmd[0] = 0x1b;	// ESC
	   _cmd[1] = (byte)'(';	//
	   _cmd[2] = (byte)'U';
	   _cmd[3] = 1;
	   _cmd[4] = 0;
	   _cmd[5] = (byte)(3600/res);
	   _send();
	   System.err.println("Set resolution "+ res);
       }
   }

   class EndOfJobCmd extends Esc300Cmd {
	public EndOfJobCmd() throws java.io.IOException {
	   _cmd = new byte[1];

	   _cmd[0] = 0x0c;	// Form feed
	   _send();
	   System.err.println("End of job.");
       }
   }
}   

