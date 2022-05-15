contract TheRichestClub { 
    /* Public variables of the token */
    address payable private issuer;
    
    enum Level { Rust, Silver, Gold, Platinum, Palladium, Tanzanite, Diamond, Alexandrite, Emerald, Ruby, BlueDiamond }
    mapping (Level => string) private levelName;
    
    struct Member {
        string firstName; 
        string lastName;
        bool exists;
    }
    
    struct Club {
        string name;
        address founder;
        address[] members;
        bool exists;
    }
    
    
    /* This creates an array with all balances */
    mapping (address => Level) public status;
    mapping (Level => uint) public price;
    mapping (address => Member) public members;
    mapping (address => Club) public clubs;
    mapping (address => Club) public pendingInvitations;
    
    /* This generates a public event on the blockchain that will notify clients */
    //event Transfer(address indexed from, address indexed to, uint256 value);
    //event FrozenFunds(address target, bool frozen);
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor() {
        levelName[Level.Rust]           = "Rust";
        levelName[Level.Silver]         = "Silver";
        levelName[Level.Gold]           = "Gold";
        levelName[Level.Platinum]       = "Platinum";
        levelName[Level.Palladium]      = "Palladium";
        levelName[Level.Tanzanite]      = "Tanzanite";
        levelName[Level.Diamond]        = "Diamond";
        levelName[Level.Alexandrite]    = "Alexandrite";
        levelName[Level.Emerald]        = "Emerald";
        levelName[Level.Ruby]           = "Ruby";
        levelName[Level.BlueDiamond]    = "BlueDiamond";
        
        price[Level.Silver]         =    1 * 1 ether;
        price[Level.Gold]           =    5 * 1 ether;
        price[Level.Platinum]       =   20 * 1 ether;
        price[Level.Palladium]      =   56 * 1 ether;
        price[Level.Tanzanite]      =  100 * 1 ether;
        price[Level.Diamond]        =  195 * 1 ether;
        price[Level.Alexandrite]    =  285 * 1 ether;
        price[Level.Emerald]        =  415 * 1 ether;
        price[Level.Ruby]           =  580 * 1 ether;
        price[Level.BlueDiamond]    = 1001 * 1 ether;
        
        issuer = payable(msg.sender);
    }

    function acquireStatus(Level level) public payable
    {
        require(level > Level.Rust && level <= Level.BlueDiamond, "Invalid level desired");
        require(msg.value >= price[level], "Seems like you're not that rich");
        
        status[msg.sender] = level;
        issuer.transfer(price[level]);
        payable(msg.sender).transfer(msg.value - price[level]);
    }
    
    function register(string memory firstName, string memory lastName) public
    {
        require(status[msg.sender] > Level.Rust, "Registration requires at least Silver level");
        require(!members[msg.sender].exists, "You've already registered");
        Member memory newMember = Member(firstName, lastName, true);
        members[msg.sender] = newMember;
    }
    
    modifier onlyIssuer {
        require(msg.sender != issuer);
        _;
    }
    
    function getStatus() public view returns (Level)
    {
        return status[msg.sender];
    }
    
    function createClub(string calldata clubName) public payable
    {
        //Todo: bound string lenght
        require(clubs[msg.sender].exists == false, "You have already created your club");
        require(msg.value >= 50 * 1 ether || status[msg.sender] >= Level.Alexandrite, "Creating clubs requires Alexandrite level or extra 50.0 ETH");
        
        Club memory newClub = Club(clubName, msg.sender, new address[](0), true);
        clubs[msg.sender] = newClub;
        
        issuer.transfer(msg.value);
    }
    
    function inviteMember(address memberAddress) public 
    {
        require(clubs[msg.sender].exists, "You haven't created a club yet");
        require(status[memberAddress] > Level.Rust, "You can only invite member whose level is Silver or better");
        require(status[memberAddress] <= status[msg.sender], "You can't invite members with higher level than yours");
        require(!pendingInvitations[memberAddress].exists, "The member you're trying to invite have an invitation pending already");
        
        pendingInvitations[memberAddress] = clubs[msg.sender];
    }
    
    function acceptInvitation() public
    {
        require(pendingInvitations[msg.sender].exists, "You have no invitations pending");
        
        address clubFounder = pendingInvitations[msg.sender].founder;
        
        clubs[clubFounder].members.push(msg.sender);
        
        delete pendingInvitations[msg.sender];
    }
    
    function declineInvitation() public
    {
        delete pendingInvitations[msg.sender];
    }
    
    function getPendingInvitation() public returns (string memory)
    {
        require(pendingInvitations[msg.sender].exists, "You have no invitations pending");
        return pendingInvitations[msg.sender].name;
    }
    
    function payout() public payable onlyIssuer
    {
        issuer.transfer(address(this).balance);
    }
    
}
