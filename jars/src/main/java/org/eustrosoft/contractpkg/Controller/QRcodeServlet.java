package org.eustrosoft.contractpkg.Controller;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Hashtable;

public class QRcodeServlet extends HttpServlet {

    private final String P_CODING_STRING = "p_codingString";
    private final String P_IMG_FORMAT = "p_imgFormat";
    private final String P_IMG_SIZE = "p_imgSize";
    private final String P_IMG_COLOR = "p_imgColor";
    private final String [] PARAMETERS = {P_CODING_STRING, P_IMG_SIZE, P_IMG_COLOR};

    private final String PNG_FORMAT = "PNG";
    private final String JPG_FORMAT = "JPG";
    private final String SVG_FORMAT = "SVG";
    private final String [] IMG_FORMATS = {PNG_FORMAT,JPG_FORMAT,SVG_FORMAT};

    private String codingString;
    private String imgFormat;
    private Color imgColor;
    private int imgSize;

    //doGet method to create QR image (using engine/qr in jsp)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws  IOException, NumberFormatException {
        OutputStream str= resp.getOutputStream();
        try {
            setParameters(req);

            String toQR = "http://qr.qxyz.ru/?q=" + codingString + "&f=" + imgFormat + "&s=" + imgSize + "&c=" + imgColor;

            createQRImage(str, imgSize, imgFormat, imgColor, toQR);
        } catch (WriterException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void setParameters(HttpServletRequest request) throws Exception {
        codingString = request.getParameter(P_CODING_STRING);
        imgSize = Integer.parseInt(request.getParameter(P_IMG_SIZE));
        imgFormat = request.getParameter(P_IMG_FORMAT);
        for(int i = 0; i < IMG_FORMATS.length; i++){
            if(imgFormat.equals(IMG_FORMATS[i]))
                break;
            if(i == IMG_FORMATS.length - 1)
                throw new Exception("Unrecognized format!");
        }
        imgColor = Color.getColor(request.getParameter(P_IMG_COLOR));
    }

    // Main method to create qr image
    public void createQRImage(OutputStream outStream, int size, String fileType, Color imgColor, String qrCodeText)
            throws WriterException, IOException {
        // Decoding context
        Hashtable<EncodeHintType, ErrorCorrectionLevel> hintMap = new Hashtable();
        hintMap.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.L);
        QRCodeWriter qrCodeWriter = new QRCodeWriter();
        // Get size of future picture
        // Set matrix parameters
        BitMatrix byteMatrix = qrCodeWriter.encode(qrCodeText, BarcodeFormat.QR_CODE, size, size, hintMap);

        int matrixWidth = byteMatrix.getWidth();
        // Create buff image
        BufferedImage image = new BufferedImage(matrixWidth, matrixWidth, BufferedImage.TYPE_INT_RGB);
        image.createGraphics();
        Graphics2D graphics = (Graphics2D) image.getGraphics();
        // BG color
        graphics.setColor(Color.WHITE);
        // Filling the plain
        graphics.fillRect(0, 0, matrixWidth, matrixWidth);

        // QR code color (black generally)
        graphics.setColor(imgColor);
        for (int i = 0; i < matrixWidth; i++) {
            for (int j = 0; j < matrixWidth; j++) {
                if (byteMatrix.get(i, j)) {
                    graphics.fillRect(i, j, 1, 1);
                }
            }
        }
        // Writing image finally
        ImageIO.write(image, fileType, outStream);
    }

}
