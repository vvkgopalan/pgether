// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;
contract Table {
	address public table_owner = msg.sender;

	event write(string query);

	struct table_name {
	    string contents;
		address owner;
		uint blocknum;
	}
	
	mapping(uint256 => table_name) public records;

	function exists(uint256 key) public view returns (bool ex) {
	    // Owner is address(0) by default (unset mapping)
		return (records[key].owner != address(0));
	}
	
	function get_table_owner() public view returns (address owner) {
	    return (table_owner); 
	}
	
	function insert_one(uint256 key, string memory contents,
	                    string memory query) public returns (bool success) {
	    
	    address owner = msg.sender;                    
        	                        
	    if(exists(key)) {
	        // Revert returns false - bubbles up
	        revert('Primary key already exists.');
	    }
	    
	    records[key].contents = contents;
	    records[key].owner = owner;
	    records[key].blocknum = block.number+1;
	    
	    emit write(query);
	    
		return (true);
	}
	
	function insert_many(uint256[] calldata key, string[] memory contents, 
	                    string memory query, uint numelem) public returns (bool success) {
	    
	    address owner = msg.sender;
	    
	    for (uint i = 0; i < numelem; i++) {
    	    if(exists(key[i])) {
    	        // Revert returns false - bubbles up
    	        revert('Primary key already exists.');
    	    }
	    }
	    
	    for (uint i = 0; i < numelem; i++) {
    	    records[key[i]].contents = contents[i];
    	    records[key[i]].owner = owner;
    	    records[key[i]].blocknum = block.number+1;
	    }
	    
	    emit write(query);
	    
		return (true);
	}

	function update_one(uint256 key, string memory contents, 
	                    uint most_recent_block, string memory query) public returns (bool success) {
	                        
        address owner = msg.sender;
        
	    if(!exists(key)) {
	        // Revert returns false - bubbles up
	        revert('Primary key does not exist.');
	    }
	    
	    if (records[key].blocknum > most_recent_block) {
	        revert('Isolation error (most recent local block < most recent update).');
	    } else if (records[key].owner != owner) {
	        revert('Caller is not owner of record.');
	    }

	    records[key].contents = contents;
	    records[key].blocknum = block.number+1;
	    
	    emit write(query);
	    
		return (true);
	}
	
	function upate_many(uint256[] calldata key, string[] memory contents, 
	                    uint most_recent_block, 
	                    string memory query, uint numelem) public returns (bool success) {
	                        
        address owner = msg.sender;
        
	    for (uint i = 0; i < numelem; i++) {
    	    if(!exists(key[i])) {
    	        // Revert returns false - bubbles up
    	        revert('Primary key does not exist.');
    	    }
    	    
    	    if (records[key[i]].blocknum > most_recent_block) {
    	        revert('Isolation error (most recent local block < most recent update).');
    	    } else if (records[key[i]].owner != owner) {
    	        revert('Caller is not owner of record.');
    	    }
	    }
	    
	    for (uint i = 0; i < numelem; i++) {
    	    records[key[i]].contents = contents[i];
    	    records[key[i]].blocknum = block.number+1;
	    }
	    
	    emit write(query);
	    
		return (true);
	}

    function delete_one(uint256 key, uint most_recent_block, 
                        string memory query) public returns (bool success) {

        address owner = msg.sender;

	    if(!exists(key)) {
	        // Revert returns false - bubbles up
	        revert('Primary key does not exist.');
	    }
	    
	    if (records[key].blocknum > most_recent_block) {
	        revert('Isolation error (most recent local block < most recent update).');
	    } else if (records[key].owner != owner) {
	        revert('Caller is not owner of record.');
	    }
	    
	    delete records[key];
	    
	    emit write(query);
	    
		return (true);
	}
	
	function delete_many(uint256[] calldata key, uint most_recent_block, 
                        string memory query, uint numelem) public returns (bool success) {
        
        address owner = msg.sender;
        
        for (uint i = 0; i < numelem; i++) {
            if(!exists(key[i])) {
    	        // Revert returns false - bubbles up
    	        revert('Primary key does not exist.');
    	    }
    	    
    	    if (records[key[i]].blocknum > most_recent_block) {
    	        revert('Isolation error (most recent local block < most recent update).');
    	    } else if (records[key[i]].owner != owner) {
    	        revert('Caller is not owner of record.');
    	    }
        }
	    
	    for (uint i = 0; i < numelem; i++) {
	       delete records[key[i]];
	    }
	    
	    emit write(query);
	    
		return (true);
	}
	
	function select_one(uint256 key) public view returns (string memory ret) {

        string memory val; 

	    if(exists(key)) {
	        val = records[key].contents;
	    }
	    
		return (val);
	}
	
	function select_many(uint256[] calldata key, uint numelem) public view returns (string[] memory ret) {
        
        string[] memory vals = new string[](numelem);
        
        for (uint i = 0; i < numelem; i++) {
            if(exists(key[i])) {
    	        // Appends if key exists, otherwise quietly ignores
    	        vals[i] = records[key[i]].contents;
    	    }
        }
	    
		return (vals);
	}

}