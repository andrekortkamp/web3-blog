//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Blog {
    string public name;
    address public owner;

    using Counters for Counters.Counter;
    Counters.Counter private _postIds;

    struct Post {
      uint id;
      string title;
      string content;
      bool published;
    }
    /* mapeamentos podem ser vistos como tabelas de hash */
    /* aqui criamos pesquisas para posts por id e posts por ipfs hash */
    mapping(uint => Post) private idToPost;
    mapping(string => Post) private hashToPost;

    /* eventos facilitam a comunicação entre contratos inteligentes e suas interfaces de usuário */
    /* ou seja, podemos criar listeners para eventos no cliente e também usá-los no The Graph */
    event PostCreated(uint id, string title, string hash);
    event PostUpdated(uint id, string title, string hash, bool published);

    /* quando o blog for implantado, dê um nome a ele */
    /* também define o criador como proprietário do contrato */
    constructor(string memory _name) {
        console.log("Deploying Blog with name:", _name);
        name = _name;
        owner = msg.sender;
    }

    /* atualiza o nome do blog */
    function updateName(string memory _name) public {
        name = _name;
    }

    /* transfere a propriedade do contrato para outro endereço */
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    /* busca um post individual pelo hash de conteúdo */
    function fetchPost(string memory hash) public view returns(Post memory){
      return hashToPost[hash];
    }

    /* cria um novo post */
    function createPost(string memory title, string memory hash) public onlyOwner {
        _postIds.increment();
        uint postId = _postIds.current();
        Post storage post = idToPost[postId];
        post.id = postId;
        post.title = title;
        post.published = true;
        post.content = hash;
        hashToPost[hash] = post;
        emit PostCreated(postId, title, hash);
    }

    /* atualiza um post existente */
    function updatePost(uint postId, string memory title, string memory hash, bool published) public onlyOwner {
        Post storage post =  idToPost[postId];
        post.title = title;
        post.published = published;
        post.content = hash;
        idToPost[postId] = post;
        hashToPost[hash] = post;
        emit PostUpdated(post.id, title, hash, published);
    }

    /* busca todos os posts */
    function fetchPosts() public view returns (Post[] memory) {
        uint itemCount = _postIds.current();

        Post[] memory posts = new Post[](itemCount);
        for (uint i = 0; i < itemCount; i++) {
            uint currentId = i + 1;
            Post storage currentItem = idToPost[currentId];
            posts[i] = currentItem;
        }
        return posts;
    }

    /* este modificador significa que apenas o proprietário do contrato pode */
    /* invoca a função */
    modifier onlyOwner() {
      require(msg.sender == owner);
    _;
  }
}