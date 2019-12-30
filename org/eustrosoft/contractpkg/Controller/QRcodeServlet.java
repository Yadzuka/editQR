package org.eustrosoft.contractpkg.Controller;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Hashtable;

/*
    Creating QR using zxing class
 */
public class QRcodeServlet extends HttpServlet {

    //doGet method to create QR image (using engine/qr in jsp)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        OutputStream str= resp.getOutputStream();
        String codingString = req.getParameter("codingString");
        String toQR = "http://qr.qxyz.ru/?q=" + codingString;
        try {
            createQRImage(str,125,"PNG",toQR);
        } catch (WriterException e) {
            e.printStackTrace();
        }
    }

    // Main method to create qr image
    public void createQRImage(OutputStream outStream, int size, String fileType,String qrCodeText)
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
        graphics.setColor(Color.BLACK);
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
