package com.clv.nhacvo.printer.barcode;

import com.clv.nhacvo.printer.EscPosPrinterSize;
import com.clv.nhacvo.printer.EscPosPrinterCommands;
import com.clv.nhacvo.printer.exceptions.EscPosBarcodeException;

public class Barcode128 extends Barcode {
    public Barcode128(EscPosPrinterSize printerSize, String code, float widthMM, float heightMM, int textPosition) throws EscPosBarcodeException {
        super(printerSize, EscPosPrinterCommands.BARCODE_TYPE_128, code, widthMM, heightMM, textPosition);
    }

    @Override
    public int getCodeLength() {
        return this.code.length();
    }

    @Override
    public int getColsCount() {
        return (this.getCodeLength() + 5) * 11;
    }
}
