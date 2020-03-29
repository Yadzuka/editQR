
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
function setQR(field_id,qr) { // SIC! а вообще это надо переделать
    let qrfield = document.getElementById(field_id);
    qrfield.value = qr;
}
