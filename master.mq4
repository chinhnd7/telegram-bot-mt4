#property copyright "Copyright 2023, Developed by Junkyu !!!"
#property link      "https://mrk.vn"
#property version   "1.00"
#property strict

extern string serverUrl = "http://localhost";

int OnInit() {
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

void OnTick() {
    string ordersString = ListOrders();
    Print(ordersString);
    SendPOSTToServers(serverUrl + "/orders", ListOrders());
}

void SendPOSTToServers(string url, string ordersString) {
    string cookie = NULL, headers;
    char post[], result[];
    int res;

    StringToCharArray(ordersString, post, 0, -1, CP_UTF8);
    ArrayResize(post, ArraySize(post));

    ResetLastError();

    res = WebRequest("POST", url, cookie, NULL, 5000, post, 0, result, headers);
    if (res == -1) {
        Print("Error: ", GetLastError());
    } else {
        Print("Send orders to server successfully");
    }
}

string ListOrders() {
    string sLO = "{\"server\":\"Junkyu\",\"total\":\"3\"";
    int sum = RunningOrders(); // Tổng số lệnh đang chạy (SELL/BUY)

    if(sum==0) {
        sum = sum + "}";
    } else {
        sLO = "{\"server\":\"Junkyu\",\"total\":\"{0}\"";
        // do cac lenh dang chay
        sLO += ", \"orders\":[";

        int orderNumber = 0;
        for (int pos=0; pos < OrdersTotal(); pos++) {
            if(OrderSelect(pos, SELECT_BY_POS)==false) continue;
            if(OrderType() == OP_BUY || OrderType() == OP_SELL){
                orderNumber++;

                if(orderNumber > 1) {
                    sLO += ",";
                }
                sLO += "{\"ticket\":\"[0]\", \"pair\":\"[1]\", \"direction\":\"[2]\", \"lot\":\"[3]\", \"price\": \"[4]\", \"sl\", \"tp\", \"opentime\", \"comment\"}";
            }
            StringReplace(sLO, "{0}", sum);
            StringReplace(sLO, "[0]", OrderTicket());
            StringReplace(sLO, "[1]", OrderSymbol());
            StringReplace(sLO, "[2]", OrderType());
            StringReplace(sLO, "[3]", OrderLots());
            StringReplace(sLO, "[4]", OrderOpenPrice());
            StringReplace(sLO, "[5]", OrderStopLoss());
            StringReplace(sLO, "[6]", OrderTakeProfit());
            StringReplace(sLO, "[7]", OrderOpenTime());
            StringReplace(sLO, "[8]", OrderComment());
        }
        sLO += "]";
        sLO += "}";
    }
    return sLO;
}

int RunningOrders() {
    int no = 0;
    for (int pos=0; pos<OrdersTotal(); pos++) {
        if(OrderSelect(pos, SELECT_BY_POS)==false) {
            continue;
        }
        if(OrderType() == OP_BUY || OrderType() == OP_SELL) {
            if(MathAbs(OrderStopLoss()) > 0 && MathAbs(OrderTakeProfit()) > 0) {
                if(MathAbs(OrderStopLoss() - OrderOpenPrice()) < MathAbs(OrderTakeProfit() - OrderOpenPrice())) {
                    no = no + 1;
                }
            }
        }
    }
    return no;
} 