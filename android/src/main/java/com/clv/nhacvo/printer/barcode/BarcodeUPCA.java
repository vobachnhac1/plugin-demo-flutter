package com.clv.nhacvo.printer.barcode;

import com.clv.nhacvo.printer.EscPosPrinterCommands;
import com.clv.nhacvo.printer.EscPosPrinterSize;
import com.clv.nhacvo.printer.exceptions.EscPosBarcodeException;

public class BarcodeUPCA extends BarcodeNumber {

    public BarcodeUPCA(EscPosPrinterSize printerSize, String code, float widthMM, float heightMM, int textPosition) throws EscPosBarcodeException {
        super(printerSize, EscPosPrinterCommands.BARCODE_TYPE_UPCA, code, widthMM, heightMM, textPosition);
    }

    @Override
    public int getCodeLength() {
        return 12;
    }
}
