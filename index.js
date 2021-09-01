var express = require('express'),
    fs = require('fs'),
app = express(); 
var util = require( "util" );    
const odbc = require('odbc');

// pdfview ... to view and download pdfs in a Win/Mac browser page
// Example: http://myibmi:15001/pdfview?pdfname=/tmp/salesOrders/200001.PDF
//   or     http://myibmi:15001/pdfview?id=1&rnd=7745&logSchema=FAQ400&logTable=PDFVIEW0F
app.get('/pdfview', function (req, res) {
    var pdfname = req.query.pdfname;
    var id = req.query.id;
    var rnd = req.query.rnd;
    var logSchema = req.query.logSchema;
    var logTable  = req.query.logTable;

    // Defaults for logSchema (FAQ400 Library) and logTable (PDFVIEW0F)
    if (typeof logSchema==='undefined') {
        var vlogSchema='FAQ400';
    } else { var vlogSchema=logSchema; };

    if (typeof logTable==='undefined') {
        var vlogTable='PDFVIEW0F';
    } else { var vlogTable=logTable; };

    
    // if pdfname not passed, try to get it from id/rnd keys on PDFVIEW0F
    if ((typeof pdfname === 'undefined') && (typeof id !== 'undefined')  && (typeof rnd !== 'undefined')) {
        var cmdsql='select PDF_PATH, viewsAllowed, views from '
                   + trim(vlogSchema)+'.'+trim(vlogTable) +
                   ' where id=? and rnd=?                 \
                        fetch first 1 rows only';
        try {
            odbc.connect('DSN=*LOCAL', (error, connection) => {
                if (error) { throw error; }
                connection.query(cmdsql, [id, rnd], (error, result) => {
                   // ODBC Error 
                   if (error) { throw error; }
                   console.log("id passed "+id);
                   console.log("rnd passed "+rnd);
                   // Get pdfpath and views counters
                  try { pdfname=result[0].PDF_PATH}
                  catch (error) {console.log(error)};
                  try { viewsAllowed=result[0].VIEWSALLOWED}
                  catch (error) {console.log(error)};
                  try { views=result[0].VIEWS}
                  catch (error) {console.log(error)};

                  // If record found ... check for Views Counter
                   if (typeof pdfname !== 'undefined') {
                    // If view Allowed
                    if (viewsAllowed>views) {
                        var cmdsqlu='update ' 
                            + trim(vlogSchema)+'.'+trim(vlogTable) +
                            ' set views=views+1                    \
                              where id=? and rnd=?';
                        connection.query(cmdsqlu, [id, rnd], (error, result) => {
                        });

                      fs.readFile(pdfname , function (err,data){
                      res.contentType("application/pdf");
                      res.send(data);
                      });
                    }
                    // if no more views allowed
                    else {
                        res.contentType("html");
                        res.send("<HTML><B>No more views allowed!</B>");

                    };
                    
                    
            }
            // if record not found
            else{
                res.contentType("html");
                res.send("<HTML><B>Not found! Check ID or RND number!</B>");

            };



                });
            
                });
            }
            catch (error) { // if something goes wrong, like SQL error, catch those here. 
                console.log(error);
            }

            
    }
    else{
        console.log("pdfname momento 3 "+pdfname);
        fs.readFile(pdfname , function (err,data){
            res.contentType("application/pdf");
            res.send(data);
        });  

    }

    
});




app.listen(15001, function(){

    console.log('Listening on 15001');
});