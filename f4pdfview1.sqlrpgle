**free
// -----------------------------------------
// F4PDFVIEW1 Via a PDF in a secure way through
//            a node.js App
//-------------------------------------------------

ctl-opt option(*srcstmt:*nounref) dftactgrp(*no);
ctl-opt bnddir('FAQ400SRV');

/INCLUDE '/home/Opensource/f4pdfview/f4srvpgmd.sqlrpgle'

dcl-s pdf_pathname varchar(256);

// My PDF Path name
pdf_pathname='/tmp/salesOrders/210001.pdf';

// View PDF
pdf_view(pdf_pathname:1);

// End
*inlr=*on;
return;

 
