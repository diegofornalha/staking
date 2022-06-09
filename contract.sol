// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract StakingToken is ERC20, Ownable {
    using SafeMath for uint256;

    /**
     * @notice Exigimos saber quem são todas as partes interessadas.
     */
    address[] internal stakeholders;

    /**
     * @notice Os Stakes são feitos para cada parte interessada.
     */
    mapping(address => uint256) internal stakes;

    /**
     * @notice As recompensas acumuladas para cada parte interessada.
     */
    mapping(address => uint256) internal rewards;

    /**
     * @notice O construtor para o Staking Token.
     * @param _owner O endereço para receber todos os tokens na construção.
     * @param _supply A quantidade de fichas para cunhar na construção.
     */
    constructor(address _owner, uint256 _supply) 
        public
    { 
        _mint(_owner, _supply);
    }

    // ---------- STAKES ----------

/**
     * @notice Um método para uma parte interessada criar uma participação.
     * @param _stake O tamanho do stake a ser criado.
     */
    function createStake(uint256 _stake)
        public
    {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }

/**
     * @notice Um método para uma parte interessada remover uma participação.
     * @param _stake O tamanho da aposta a ser removida.
     */
    function removeStake(uint256 _stake)
        public
    {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        _mint(msg.sender, _stake);
    }

    /**
* @notice Um método para recuperar a participação de uma parte interessada.
     * @param _stakeholder O stakeholder para o qual recuperar a participação.
     * @return uint256 A quantidade de wei apostada.
     */
    function stakeOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder];
    }

    /**
    * @notice Um método para as participações       agregadas de todas as partes interessadas.
     * @return uint256 As participações             agregadas de todas as partes interessadas.
     */
    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }

    // ---------- PARTES INTERESSADAS ----------

    /**
* @notice Um método para verificar se um endereço é uma parte interessada.
     * @param _address O endereço a ser verificado.
     * @return bool, uint256 Se o endereço for uma parte interessada,
     * e em caso afirmativo sua posição na matriz de stakeholders.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
     * @notice Um método para adicionar uma parte interessada.
     * @param _stakeholder A parte interessada a ser adicionada.
     */
    function addStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /**
     * @notice Um método para remover uma parte interessada.
     * @param _stakeholder A parte interessada a ser removida.
     */
    function removeStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }

    // ---------- RECOMPENSAS ----------
    
    /**
     * @notice Um método para permitir que uma parte interessada verifique suas recompensas.
     * @param _stakeholder A parte interessada para verificar as recompensas.
     */
    function rewardOf(address _stakeholder) 
        public
        view
        returns(uint256)
    {
        return rewards[_stakeholder];
    }

    /**
     * @notice Um método para as recompensas agregadas de todas as partes interessadas.
     * @return uint256 As recompensas agregadas de todas as partes interessadas.
     */
    function totalRewards()
        public
        view
        returns(uint256)
    {
        uint256 _totalRewards = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
        }
        return _totalRewards;
    }

    /** 
     * @notice Um método simples que calcula as recompensas para cada parte interessada.
     * @param _stakeholder A parte interessada para calcular as recompensas.
     */
    function calculateReward(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder] / 100;
    }

    /**
     * @notice Um método para distribuir recompensas a todas as partes interessadas.
     */
    function distributeRewards() 
        public
        onlyOwner
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }

    /**
     * @notice Um método para permitir que uma parte interessada retire suas recompensas.
     */
    function withdrawReward() 
        public
    {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }
}
