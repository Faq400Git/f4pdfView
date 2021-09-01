**free
//------------------------------------------------------
// F4SRVPGM Faq400 Service Program with some
//          procedures' example
//
// To compile:
// 1 CRTSQLRPGI OBJ(FAQ400/F4SRVPGM) SRCFILE(FAQ400/SRV)
//   SRCMBR(F4SRVPGM) OBJTYPE(*MODULE) OPTION(*EVENTF)
//   REPLACE(*YES) DBGVIEW(*SOURCE)
// 2 CRTSRVPGM SRVPGM(FAQ400/F4SRVPGM)
//   MODULE(FAQ400/F4SRVPGM) EXPORT(*ALL)
//   ACTGRP(*CALLER)
// 3 ADDBNDDIRE BNDDIR(yourBNDDIR) OBJ((FAQ400SRV))
//------------------------------------------------------

ctl-opt NOMAIN DECEDIT(*JOBRUN) DATEDIT(*DMY/);
ctl-opt OPTION(*NODEBUGIO) CCSID(*CHAR : *JOBRUN);

//----------------------------------------------------
// Faq400 Service program Example
//----------------------------------------------------

/copy SRV,F4SRVPGMD

dcl-pr QCMDEXC extpgm ;
   *n char(256) options(*varsize) const ;
   *n packed(15:5) const;
end-pr ;

//**********************************************************
// Procedure pdf_view(ifs_path_to_doc) to view PDF in
// a secure way through a Node.js App
//
//----------------------------------------------------------
// Exampe
//  pdf_view('/salesOrders/2100001.pdf':1);
//***********************************************************
dcl-proc pdf_view  export;
 dcl-pi  pdf_view;
         i_mypdfdoc  varchar(256) const;
         i_ViewsAllowed int(5) const options(*nopass);
 END-PI;
dcl-s cmd     varchar(256);
dcl-s user  char(10) inz(*USER);
dcl-s id      int(5);
dcl-s rnd     int(5);
dcl-s viewsAllowed int(5);
dcl-s NodeJsServer varchar(256) inz('http://192.168.18.2:5001/pdfview');

// Check viewsAllowed ... default 1
select;
   when %parms=1;
        viewsAllowed=1;
   when i_viewsAllowed=0;
        viewsAllowed=1;
   other;
        viewsAllowed=i_viewsAllowed;
ENDSL;


 // If my job run in 65535 CCSID I need to set a CCSID
cmd='CHGJOB CCSID(280)';
qcmdexc(cmd:%len(%trimr(cmd)));



//  Insert a record in the PDFVIEW0F table with pdf_pathname
//  and a random key
 exec sql
     select id, rnd into :id, :rnd
         from final table(
            insert into faq400.pdfview0f
              (rnd, pdf_path, ViewsAllowed)
             values(
               CAST((CAST(RAND() AS DECIMAL(9, 5))*10000) AS DECIMAL(5, 0)),
               trim(:i_mypdfdoc),
               :ViewsAllowed)
                   );

 // Reset CCSID
cmd='CHGJOB CCSID(*USRPRF)';
qcmdexc(cmd:%len(%trimr(cmd)));

 // Start PCO (if not just started)
cmd='STRPCO';
monitor;
qcmdexc(cmd:%len(%trimr(cmd)));
on-error;  // don't worry about IWS4010 msg
endmon;


// STRPCCMD passing the URL for our Node.js Web Server
cmd='STRPCCMD   PCCMD(''start '+NodeJsServer
     +'?id='
     +%editc(id:'X')
     +'^&rnd='   // Pay attention to the escape char ^ before &
     +%editc(rnd:'X')
     +''')  PAUSE(*NO)';

qcmdexc(cmd:%len(%trimr(cmd)));

return;



 end-proc;
 
