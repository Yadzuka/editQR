
function allertToDeleteRecord(){
    let answer = confirm("Do you really want do delete the record?");
    if(answer === true)
        return true;
    else
        return false;
}

function newQR(qr) {
    var qrfield = document.getElementById(qrcode);
    qrfield.innerText = qr;
    qrfield.innerHTML = qr;
}