
function allertToDeleteRecord(){
    let answer = confirm("Do you really want do delete the record?");
    if(answer === true)
        return true;
    else
        return false;
}

function newQR(qr) {
    let qrfield = document.getElementById("qrcode");
    qrfield.value = qr;
}