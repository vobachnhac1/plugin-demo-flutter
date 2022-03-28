package com.clv.nhacvo.printer.textparser;

import com.clv.nhacvo.printer.EscPosPrinterCommands;
import com.clv.nhacvo.printer.exceptions.EscPosEncodingException;

public interface IPrinterTextParserElement {
    int length() throws EscPosEncodingException;
    IPrinterTextParserElement print(EscPosPrinterCommands printerSocket) throws EscPosEncodingException;
}
