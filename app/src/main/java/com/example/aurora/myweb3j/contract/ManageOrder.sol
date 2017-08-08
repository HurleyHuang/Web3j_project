pragma solidity ^0.4.11;
contract ManageOrder{
 address public owner;
 uint256 count;
 uint256 count_parking;
 string order_list;
 uint256 order_number;
 string public result;
 struct Order {
        uint256 orderNo;
        address buyer;
        address seller;
        uint256 parkingNo;
        State state;
        string new_hour;
        uint256 price;
        uint date;
    }
struct Parking {
        uint256 parkingNo;
        address seller;
        string name;
        string phone;
        string post_code;
        string avail_hour;
        string park_address;
    }
    mapping(uint => Order) private Orders;
    mapping(uint => Parking) private Parkings;
    mapping(address => uint256) balances;
 enum State { Created, Pending, Completed, Aborted }

 function ManageOrder(){
 owner = msg.sender;
 count = 0;
 count_parking=0;
 }

 modifier onlyBuyer(uint256 order_no) {
        require(msg.sender == Orders[order_no].buyer);
        _;
    }

 modifier onlySeller(uint256 order_no) {
        require(msg.sender == Orders[order_no].seller);
        _;
    }

 modifier inState(State _state, uint256 order_no) {
        require(Orders[order_no].state == _state);
        _;
    }

 modifier isMoney(uint _price){
        require(balances[msg.sender]>=_price);
        _;
    }
 modifier isSeller(uint parkingNo){
         //sha3(...) returns (bytes32)
    require(sha3(Parkings[parkingNo].post_code)!=0);
    _;
 }

 function depositEther(uint _value) returns (bool success){
     if(balances[msg.sender]<0){
     return false;}

     balances[msg.sender]+=_value;
     return true;
 }

   function newParking(string _name, string _phone, string _post_code, string _park_address) {
    bool parking_exist = false;
    uint parking_no;
    for(uint i=1; i<=count_parking; i++){
        if (Parkings[count_parking].seller == msg.sender){
            parking_exist = true;
            parking_no = count_parking;
        }
    }
    if(!parking_exist){
        count_parking++;
    var new_Parking = Parking({
            parkingNo:count_parking,
            seller:msg.sender,
            name:_name,
            phone: _phone,
            post_code:_post_code,
            avail_hour:"000000000000000000000000000000000000000000000000000000000000000000000000",
            park_address:_park_address
        });
    Parkings[count_parking] = new_Parking;
    }else{
        Parkings[parking_no].name = _name;
        Parkings[parking_no].phone = _phone;
        Parkings[parking_no].post_code = _post_code;
        Parkings[parking_no].park_address= _park_address;
    }

 }
 function numParking() constant returns (string){
    for(uint i=1; i<=count_parking; i++){
        if (Parkings[count_parking].seller == msg.sender){
            result = strConcat2(strConcat1(Parkings[count_parking].name, Parkings[count_parking].phone, Parkings[count_parking].post_code), Parkings[count_parking].avail_hour, Parkings[count_parking].park_address,uintToString(count_parking));

        }
    }
    return result;
 }

 function manageParking(uint256 _parkingNo, string _avail_hour)
 isSeller(_parkingNo)
 {
    if(Parkings[_parkingNo].seller == msg.sender)
    Parkings[_parkingNo].avail_hour= _avail_hour;
 }

 function newOrder(uint256 _parkingNo, uint256 _price, string _avail_hour, string _new_hour)
        isMoney(_price)
        isSeller(_parkingNo)
    {
        //sha3(...) returns (bytes32)
    //require(sha3(Parkings[_seller].post_code)!=0);
    //require(_price==msg.value);
    count = count+1;

    var new_Order = Order({
            orderNo: count,
            parkingNo: _parkingNo,
            buyer: msg.sender,
            seller:Parkings[_parkingNo].seller,
            state: State.Created,
            new_hour:_new_hour,
            price:_price,
            date:now
        });
    Orders[count] = new_Order;
    Parkings[_parkingNo].avail_hour = _avail_hour;
    balances[Orders[count].buyer] -= _price;
    Orders[count].state = State.Pending;
 }


 function queryParking(uint _parkingNo) returns (string _hour){
    result = strConcat2(strConcat1(Parkings[_parkingNo].name, Parkings[_parkingNo].phone, Parkings[_parkingNo].post_code), Parkings[_parkingNo].avail_hour, Parkings[_parkingNo].park_address, "");
    return result;
 }


 function listedOrder() returns (string) {
    uint256 display_no = 0;
    string[4] memory sub_result ;
    for(uint256 i=0; i<count+1; i++){
      if (((Orders[i].buyer==msg.sender)||(Orders[i].seller==msg.sender))&&((Orders[i].state!=State.Completed)&&(Orders[i].state!=State.Aborted))&&(display_no<4)){
          string memory _a = uintToString(Orders[i].orderNo);
          string memory _b = uintToString(Orders[i].parkingNo);
          string memory _c = enumToString(Orders[i].state);
          string memory _d = uintToString(Orders[i].price);
          string memory _e = uintToString(Orders[i].date);

          //string memory _b =
          //bytes32 data = bytes32(123456789);
          //result = uintToString(123456789123456789);
          sub_result[display_no] = strConcat2(strConcat1(_a,_b,_c),_d,_e,Orders[i].new_hour);
          display_no++;
      }
    }
    //result = sub_result[display_no-1];
    result = ordersConcat(sub_result[0],sub_result[1],sub_result[2],sub_result[3],"");
    return result;
 }

 function strConcat1(string _a, string _b, string _c) internal returns (string){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);

    string memory abc = new string(_ba.length + _bb.length + _bc.length + 3);
    bytes memory babc = bytes(abc);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babc[k++] = _ba[i];
    babc[k++] = "*";
    for (i = 0; i < _bb.length; i++) babc[k++] = _bb[i];
    babc[k++] = "*";
    for (i = 0; i < _bc.length; i++) babc[k++] = _bc[i];


    return string(babc);
}
function strConcat2(string _a, string _b, string _c, string _d) internal returns (string){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);

    string memory abcd = new string(_ba.length + _bb.length + _bc.length + _bd.length + 4);
    bytes memory babcd = bytes(abcd);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcd[k++] = _ba[i];
    babcd[k++] = "*";
    for (i = 0; i < _bb.length; i++) babcd[k++] = _bb[i];
    babcd[k++] = "*";
    for (i = 0; i < _bc.length; i++) babcd[k++] = _bc[i];
    babcd[k++] = "*";
    for (i = 0; i < _bd.length; i++) babcd[k++] = _bd[i];
    babcd[k++] = "%";
    return string(babcd);
}

function ordersConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
}


 function abortOrder(uint256 order_no)
        onlyBuyer(order_no)
        inState(State.Pending,order_no)
    {
        Orders[order_no].state = State.Aborted;
        address buyer = Orders[order_no].buyer;
        //return the money to buyer
        buyer.transfer(Orders[order_no].price);
        balances[Orders[order_no].buyer] += Orders[order_no].price;

    }
 function confirmOrder(uint256 order_no)
        onlyBuyer(order_no)
        inState(State.Pending,order_no)
    {
        Orders[order_no].state = State.Completed;
        address seller = Orders[order_no].seller;
        seller.transfer(Orders[order_no].price);
        balances[Orders[order_no].seller] += Orders[order_no].price;
    }

function getBalance(address _user) constant returns (uint256 balance){

 return balances[_user];
 }

 function () payable {
     balances[msg.sender]+=msg.value;
 }



 function uintto() constant returns (string){
     return result;
 }
function uintToString(uint v) constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }
function enumToString(State _state) constant returns (string str){
    uint256 _temp;
    if(_state==State.Created){
        _temp = 1;
    }else if(_state==State.Pending){
        _temp = 2;
    }else if(_state==State.Completed){
        _temp = 3;
    }else {
        _temp = 4;
    }
    str = uintToString(_temp);
}
function addressToString(address x) returns (string) {
    bytes memory b = new bytes(20);
    for (uint i = 0; i < 20; i++)
        b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
    return string(b);
}

}
