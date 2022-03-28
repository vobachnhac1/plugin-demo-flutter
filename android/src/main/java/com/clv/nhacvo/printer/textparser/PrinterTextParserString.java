package com.clv.nhacvo.printer.textparser;

import java.io.UnsupportedEncodingException;
import java.util.Arrays;

import com.clv.nhacvo.printer.EscPosCharsetEncoding;
import com.clv.nhacvo.printer.EscPosPrinter;
import com.clv.nhacvo.printer.EscPosPrinterCommands;
import com.clv.nhacvo.printer.exceptions.EscPosEncodingException;

public class PrinterTextParserString implements IPrinterTextParserElement {
    private EscPosPrinter printer;
    private String text;
    private byte[] textSize;
    private byte[] textColor;
    private byte[] textReverseColor;
    private byte[] textBold;
    private byte[] textUnderline;
    private byte[] textDoubleStrike;

    public PrinterTextParserString(PrinterTextParserColumn printerTextParserColumn, String text, byte[] textSize, byte[] textColor, byte[] textReverseColor, byte[] textBold, byte[] textUnderline, byte[] textDoubleStrike) {
        this.printer = printerTextParserColumn.getLine().getTextParser().getPrinter();
        this.text = text;
        this.textSize = textSize;
        this.textColor = textColor;
        this.textReverseColor = textReverseColor;
        this.textBold = textBold;
        this.textUnderline = textUnderline;
        this.textDoubleStrike = textDoubleStrike;
    }

    @Override
    public int length() throws EscPosEncodingException {
        EscPosCharsetEncoding charsetEncoding = this.printer.getEncoding();

        int coef = Arrays.equals(this.textSize, EscPosPrinterCommands.TEXT_SIZE_DOUBLE_WIDTH) || Arrays.equals(this.textSize, EscPosPrinterCommands.TEXT_SIZE_BIG) ? 2 : 1;

        if (charsetEncoding != null) {
            try {
                return this.text.getBytes(charsetEncoding.getName()).length * coef;
            } catch (UnsupportedEncodingException e) {
                throw new EscPosEncodingException(e.getMessage());
            }
        }

        return this.text.length() * coef;
    }

    /**
     * Print text
     *
     * @param printerSocket Instance of EscPosPrinterCommands
     * @return this Fluent method
     */
    @Override
    public PrinterTextParserString print(EscPosPrinterCommands printerSocket) throws EscPosEncodingException {
        printerSocket.printText(this.text, this.textSize, this.textColor, this.textReverseColor, this.textBold, this.textUnderline, this.textDoubleStrike);
        return this;
    }
}
