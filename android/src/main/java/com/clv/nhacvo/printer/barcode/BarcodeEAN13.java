package com.clv.nhacvo.printer.barcode;

import com.clv.nhacvo.printer.EscPosPrinterCommands;
import com.clv.nhacvo.printer.EscPosPrinterSize;
import com.clv.nhacvo.printer.exceptions.EscPosBarcodeException;

public class BarcodeEAN13 extends BarcodeNumber {

    public BarcodeEAN13(EscPosPrinterSize printerSize, String code, float widthMM, float heightMM, int textPosition) throws EscPosBarcodeException {
        super(printerSize, EscPosPrinterCommands.BARCODE_TYPE_EAN13, code, widthMM, heightMM, textPosition);
    }

    @Override
    public int getCodeLength() {
        return 13;
    }
}
