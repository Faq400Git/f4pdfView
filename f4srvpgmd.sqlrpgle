**free
//**********************************************************
// Procedure pdf_view(ifs_path_to_doc) to view PDF in
// a secure way through a Node.js App
//
//----------------------------------------------------------
// Exampe
//  pdf_view('/salesOrders/2100001.pdf':1);
//***********************************************************
 dcl-pr  pdf_view;
         i_mypdfdoc  varchar(256) const;
         i_ViewsAllowed int(5) const options(*NOPASS);
 END-Pr; 
