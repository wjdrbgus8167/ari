package com.ccc.ari.global.contract;

import io.reactivex.Flowable;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.web3j.abi.EventEncoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Address;
import org.web3j.abi.datatypes.Event;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.Utf8String;
import org.web3j.abi.datatypes.generated.Bytes32;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameter;
import org.web3j.protocol.core.RemoteCall;
import org.web3j.protocol.core.RemoteFunctionCall;
import org.web3j.protocol.core.methods.request.EthFilter;
import org.web3j.protocol.core.methods.response.BaseEventResponse;
import org.web3j.protocol.core.methods.response.Log;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.tx.Contract;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;

/**
 * <p>Auto generated code.
 * <p><strong>Do not modify!</strong>
 * <p>Please use the <a href="https://docs.web3j.io/command_line.html">web3j command line tools</a>,
 * or the org.web3j.codegen.SolidityFunctionWrapperGenerator in the 
 * <a href="https://github.com/hyperledger-web3j/web3j/tree/main/codegen">codegen module</a> to update.
 *
 * <p>Generated with web3j version 1.6.3.
 */
@SuppressWarnings("rawtypes")
public class StreamingAggregationContract extends Contract {
    public static final String BINARY = "608060405234801561000f575f5ffd5b50335f73ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1603610081575f6040517f1e4fbdf70000000000000000000000000000000000000000000000000000000081526004016100789190610196565b60405180910390fd5b6100908161009660201b60201c565b506101af565b5f5f5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050815f5f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f61018082610157565b9050919050565b61019081610176565b82525050565b5f6020820190506101a95f830184610187565b92915050565b610701806101bc5f395ff3fe608060405234801561000f575f5ffd5b506004361061007b575f3560e01c80638da5cb5b116100595780638da5cb5b146100c1578063c1975f80146100df578063f2fde38b146100fb578063f79a53b6146101175761007b565b80634a68906b1461007f578063682663a11461009b578063715018a6146100b7575b5f5ffd5b610099600480360381019061009491906104fa565b610133565b005b6100b560048036038101906100b09190610557565b61017b565b005b6100bf6101c1565b005b6100c96101d4565b6040516100d691906105e1565b60405180910390f35b6100f960048036038101906100f491906104fa565b6101fb565b005b61011560048036038101906101109190610624565b610243565b005b610131600480360381019061012c91906104fa565b6102c7565b005b61013b61030f565b82427fb8d7ef907d8002b3a24c18ff9d37237687359d86556f8e7af9f9dbe3c0059143848460405161016e9291906106a9565b60405180910390a3505050565b61018361030f565b427fc50b91f34d4ba1b9972ae7f766aaa4d4992c343781d6f5334c91d74dce831f7083836040516101b59291906106a9565b60405180910390a25050565b6101c961030f565b6101d25f610396565b565b5f5f5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b61020361030f565b82427f0c7f641abf0fd5377f5f9acea29c18cb95b7f823760810ce17a4bc45cbd90ac684846040516102369291906106a9565b60405180910390a3505050565b61024b61030f565b5f73ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16036102bb575f6040517f1e4fbdf70000000000000000000000000000000000000000000000000000000081526004016102b291906105e1565b60405180910390fd5b6102c481610396565b50565b6102cf61030f565b82427fdafdb5edce57710e88dbd5e9d6399afc781b1174becf755a73e3b76c532b26fc84846040516103029291906106a9565b60405180910390a3505050565b610317610457565b73ffffffffffffffffffffffffffffffffffffffff166103356101d4565b73ffffffffffffffffffffffffffffffffffffffff161461039457610358610457565b6040517f118cdaa700000000000000000000000000000000000000000000000000000000815260040161038b91906105e1565b60405180910390fd5b565b5f5f5f9054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050815f5f6101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b5f33905090565b5f5ffd5b5f5ffd5b5f819050919050565b61047881610466565b8114610482575f5ffd5b50565b5f813590506104938161046f565b92915050565b5f5ffd5b5f5ffd5b5f5ffd5b5f5f83601f8401126104ba576104b9610499565b5b8235905067ffffffffffffffff8111156104d7576104d661049d565b5b6020830191508360018202830111156104f3576104f26104a1565b5b9250929050565b5f5f5f604084860312156105115761051061045e565b5b5f61051e86828701610485565b935050602084013567ffffffffffffffff81111561053f5761053e610462565b5b61054b868287016104a5565b92509250509250925092565b5f5f6020838503121561056d5761056c61045e565b5b5f83013567ffffffffffffffff81111561058a57610589610462565b5b610596858286016104a5565b92509250509250929050565b5f73ffffffffffffffffffffffffffffffffffffffff82169050919050565b5f6105cb826105a2565b9050919050565b6105db816105c1565b82525050565b5f6020820190506105f45f8301846105d2565b92915050565b610603816105c1565b811461060d575f5ffd5b50565b5f8135905061061e816105fa565b92915050565b5f602082840312156106395761063861045e565b5b5f61064684828501610610565b91505092915050565b5f82825260208201905092915050565b828183375f83830152505050565b5f601f19601f8301169050919050565b5f610688838561064f565b935061069583858461065f565b61069e8361066d565b840190509392505050565b5f6020820190508181035f8301526106c281848661067d565b9050939250505056fea264697066735822122096aa0bda8ea36b0d68d17b29a0bc5406815a5a202f2d599d84ba036674f337f464736f6c634300081d0033";

    private static String librariesLinkedBinary;

    public static final String FUNC_COMMITRAWALLTRACKS = "commitRawAllTracks";

    public static final String FUNC_COMMITRAWARTISTTRACKS = "commitRawArtistTracks";

    public static final String FUNC_COMMITRAWGENRETRACKS = "commitRawGenreTracks";

    public static final String FUNC_COMMITRAWLISTENERTRACKS = "commitRawListenerTracks";

    public static final String FUNC_RENOUNCEOWNERSHIP = "renounceOwnership";

    public static final String FUNC_TRANSFEROWNERSHIP = "transferOwnership";

    public static final String FUNC_OWNER = "owner";

    public static final Event OWNERSHIPTRANSFERRED_EVENT = new Event("OwnershipTransferred", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}));
    ;

    public static final Event RAWALLTRACKSUPDATED_EVENT = new Event("RawAllTracksUpdated", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>(true) {}, new TypeReference<Utf8String>() {}));
    ;

    public static final Event RAWARTISTTRACKSUPDATED_EVENT = new Event("RawArtistTracksUpdated", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>(true) {}, new TypeReference<Bytes32>(true) {}, new TypeReference<Utf8String>() {}));
    ;

    public static final Event RAWGENRETRACKSUPDATED_EVENT = new Event("RawGenreTracksUpdated", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>(true) {}, new TypeReference<Bytes32>(true) {}, new TypeReference<Utf8String>() {}));
    ;

    public static final Event RAWLISTENERTRACKSUPDATED_EVENT = new Event("RawListenerTracksUpdated", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>(true) {}, new TypeReference<Bytes32>(true) {}, new TypeReference<Utf8String>() {}));
    ;

    @Deprecated
    protected StreamingAggregationContract(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    protected StreamingAggregationContract(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, credentials, contractGasProvider);
    }

    @Deprecated
    protected StreamingAggregationContract(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    protected StreamingAggregationContract(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public RemoteFunctionCall<TransactionReceipt> commitRawAllTracks(String cid) {
        final Function function = new Function(
                FUNC_COMMITRAWALLTRACKS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Utf8String(cid)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<TransactionReceipt> commitRawArtistTracks(byte[] artistId,
            String cid) {
        final Function function = new Function(
                FUNC_COMMITRAWARTISTTRACKS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.generated.Bytes32(artistId), 
                new org.web3j.abi.datatypes.Utf8String(cid)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<TransactionReceipt> commitRawGenreTracks(byte[] genreId, String cid) {
        final Function function = new Function(
                FUNC_COMMITRAWGENRETRACKS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.generated.Bytes32(genreId), 
                new org.web3j.abi.datatypes.Utf8String(cid)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<TransactionReceipt> commitRawListenerTracks(byte[] listenerId,
            String cid) {
        final Function function = new Function(
                FUNC_COMMITRAWLISTENERTRACKS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.generated.Bytes32(listenerId), 
                new org.web3j.abi.datatypes.Utf8String(cid)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public static List<OwnershipTransferredEventResponse> getOwnershipTransferredEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(OWNERSHIPTRANSFERRED_EVENT, transactionReceipt);
        ArrayList<OwnershipTransferredEventResponse> responses = new ArrayList<OwnershipTransferredEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            OwnershipTransferredEventResponse typedResponse = new OwnershipTransferredEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.previousOwner = (String) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.newOwner = (String) eventValues.getIndexedValues().get(1).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static OwnershipTransferredEventResponse getOwnershipTransferredEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(OWNERSHIPTRANSFERRED_EVENT, log);
        OwnershipTransferredEventResponse typedResponse = new OwnershipTransferredEventResponse();
        typedResponse.log = log;
        typedResponse.previousOwner = (String) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.newOwner = (String) eventValues.getIndexedValues().get(1).getValue();
        return typedResponse;
    }

    public Flowable<OwnershipTransferredEventResponse> ownershipTransferredEventFlowable(
            EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getOwnershipTransferredEventFromLog(log));
    }

    public Flowable<OwnershipTransferredEventResponse> ownershipTransferredEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(OWNERSHIPTRANSFERRED_EVENT));
        return ownershipTransferredEventFlowable(filter);
    }

    public static List<RawAllTracksUpdatedEventResponse> getRawAllTracksUpdatedEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(RAWALLTRACKSUPDATED_EVENT, transactionReceipt);
        ArrayList<RawAllTracksUpdatedEventResponse> responses = new ArrayList<RawAllTracksUpdatedEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            RawAllTracksUpdatedEventResponse typedResponse = new RawAllTracksUpdatedEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.batchTimestamp = (BigInteger) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.cid = (String) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static RawAllTracksUpdatedEventResponse getRawAllTracksUpdatedEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(RAWALLTRACKSUPDATED_EVENT, log);
        RawAllTracksUpdatedEventResponse typedResponse = new RawAllTracksUpdatedEventResponse();
        typedResponse.log = log;
        typedResponse.batchTimestamp = (BigInteger) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.cid = (String) eventValues.getNonIndexedValues().get(0).getValue();
        return typedResponse;
    }

    public Flowable<RawAllTracksUpdatedEventResponse> rawAllTracksUpdatedEventFlowable(
            EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getRawAllTracksUpdatedEventFromLog(log));
    }

    public Flowable<RawAllTracksUpdatedEventResponse> rawAllTracksUpdatedEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(RAWALLTRACKSUPDATED_EVENT));
        return rawAllTracksUpdatedEventFlowable(filter);
    }

    public static List<RawArtistTracksUpdatedEventResponse> getRawArtistTracksUpdatedEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(RAWARTISTTRACKSUPDATED_EVENT, transactionReceipt);
        ArrayList<RawArtistTracksUpdatedEventResponse> responses = new ArrayList<RawArtistTracksUpdatedEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            RawArtistTracksUpdatedEventResponse typedResponse = new RawArtistTracksUpdatedEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.batchTimestamp = (BigInteger) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.artistId = (byte[]) eventValues.getIndexedValues().get(1).getValue();
            typedResponse.cid = (String) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static RawArtistTracksUpdatedEventResponse getRawArtistTracksUpdatedEventFromLog(
            Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(RAWARTISTTRACKSUPDATED_EVENT, log);
        RawArtistTracksUpdatedEventResponse typedResponse = new RawArtistTracksUpdatedEventResponse();
        typedResponse.log = log;
        typedResponse.batchTimestamp = (BigInteger) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.artistId = (byte[]) eventValues.getIndexedValues().get(1).getValue();
        typedResponse.cid = (String) eventValues.getNonIndexedValues().get(0).getValue();
        return typedResponse;
    }

    public Flowable<RawArtistTracksUpdatedEventResponse> rawArtistTracksUpdatedEventFlowable(
            EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getRawArtistTracksUpdatedEventFromLog(log));
    }

    public Flowable<RawArtistTracksUpdatedEventResponse> rawArtistTracksUpdatedEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(RAWARTISTTRACKSUPDATED_EVENT));
        return rawArtistTracksUpdatedEventFlowable(filter);
    }

    public static List<RawGenreTracksUpdatedEventResponse> getRawGenreTracksUpdatedEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(RAWGENRETRACKSUPDATED_EVENT, transactionReceipt);
        ArrayList<RawGenreTracksUpdatedEventResponse> responses = new ArrayList<RawGenreTracksUpdatedEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            RawGenreTracksUpdatedEventResponse typedResponse = new RawGenreTracksUpdatedEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.batchTimestamp = (BigInteger) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.genreId = (byte[]) eventValues.getIndexedValues().get(1).getValue();
            typedResponse.cid = (String) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static RawGenreTracksUpdatedEventResponse getRawGenreTracksUpdatedEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(RAWGENRETRACKSUPDATED_EVENT, log);
        RawGenreTracksUpdatedEventResponse typedResponse = new RawGenreTracksUpdatedEventResponse();
        typedResponse.log = log;
        typedResponse.batchTimestamp = (BigInteger) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.genreId = (byte[]) eventValues.getIndexedValues().get(1).getValue();
        typedResponse.cid = (String) eventValues.getNonIndexedValues().get(0).getValue();
        return typedResponse;
    }

    public Flowable<RawGenreTracksUpdatedEventResponse> rawGenreTracksUpdatedEventFlowable(
            EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getRawGenreTracksUpdatedEventFromLog(log));
    }

    public Flowable<RawGenreTracksUpdatedEventResponse> rawGenreTracksUpdatedEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(RAWGENRETRACKSUPDATED_EVENT));
        return rawGenreTracksUpdatedEventFlowable(filter);
    }

    public static List<RawListenerTracksUpdatedEventResponse> getRawListenerTracksUpdatedEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(RAWLISTENERTRACKSUPDATED_EVENT, transactionReceipt);
        ArrayList<RawListenerTracksUpdatedEventResponse> responses = new ArrayList<RawListenerTracksUpdatedEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            RawListenerTracksUpdatedEventResponse typedResponse = new RawListenerTracksUpdatedEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.batchTimestamp = (BigInteger) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.listenerId = (byte[]) eventValues.getIndexedValues().get(1).getValue();
            typedResponse.cid = (String) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static RawListenerTracksUpdatedEventResponse getRawListenerTracksUpdatedEventFromLog(
            Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(RAWLISTENERTRACKSUPDATED_EVENT, log);
        RawListenerTracksUpdatedEventResponse typedResponse = new RawListenerTracksUpdatedEventResponse();
        typedResponse.log = log;
        typedResponse.batchTimestamp = (BigInteger) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.listenerId = (byte[]) eventValues.getIndexedValues().get(1).getValue();
        typedResponse.cid = (String) eventValues.getNonIndexedValues().get(0).getValue();
        return typedResponse;
    }

    public Flowable<RawListenerTracksUpdatedEventResponse> rawListenerTracksUpdatedEventFlowable(
            EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getRawListenerTracksUpdatedEventFromLog(log));
    }

    public Flowable<RawListenerTracksUpdatedEventResponse> rawListenerTracksUpdatedEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(RAWLISTENERTRACKSUPDATED_EVENT));
        return rawListenerTracksUpdatedEventFlowable(filter);
    }

    public RemoteFunctionCall<TransactionReceipt> renounceOwnership() {
        final Function function = new Function(
                FUNC_RENOUNCEOWNERSHIP, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<TransactionReceipt> transferOwnership(String newOwner) {
        final Function function = new Function(
                FUNC_TRANSFEROWNERSHIP, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, newOwner)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<String> owner() {
        final Function function = new Function(FUNC_OWNER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    @Deprecated
    public static StreamingAggregationContract load(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return new StreamingAggregationContract(contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    @Deprecated
    public static StreamingAggregationContract load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return new StreamingAggregationContract(contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public static StreamingAggregationContract load(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        return new StreamingAggregationContract(contractAddress, web3j, credentials, contractGasProvider);
    }

    public static StreamingAggregationContract load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        return new StreamingAggregationContract(contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public static RemoteCall<StreamingAggregationContract> deploy(Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        return deployRemoteCall(StreamingAggregationContract.class, web3j, credentials, contractGasProvider, getDeploymentBinary(), "");
    }

    public static RemoteCall<StreamingAggregationContract> deploy(Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        return deployRemoteCall(StreamingAggregationContract.class, web3j, transactionManager, contractGasProvider, getDeploymentBinary(), "");
    }

    @Deprecated
    public static RemoteCall<StreamingAggregationContract> deploy(Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return deployRemoteCall(StreamingAggregationContract.class, web3j, credentials, gasPrice, gasLimit, getDeploymentBinary(), "");
    }

    @Deprecated
    public static RemoteCall<StreamingAggregationContract> deploy(Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return deployRemoteCall(StreamingAggregationContract.class, web3j, transactionManager, gasPrice, gasLimit, getDeploymentBinary(), "");
    }

    public static void linkLibraries(List<Contract.LinkReference> references) {
        librariesLinkedBinary = linkBinaryWithReferences(BINARY, references);
    }

    private static String getDeploymentBinary() {
        if (librariesLinkedBinary != null) {
            return librariesLinkedBinary;
        } else {
            return BINARY;
        }
    }

    public static class OwnershipTransferredEventResponse extends BaseEventResponse {
        public String previousOwner;

        public String newOwner;
    }

    public static class RawAllTracksUpdatedEventResponse extends BaseEventResponse {
        public BigInteger batchTimestamp;

        public String cid;
    }

    public static class RawArtistTracksUpdatedEventResponse extends BaseEventResponse {
        public BigInteger batchTimestamp;

        public byte[] artistId;

        public String cid;
    }

    public static class RawGenreTracksUpdatedEventResponse extends BaseEventResponse {
        public BigInteger batchTimestamp;

        public byte[] genreId;

        public String cid;
    }

    public static class RawListenerTracksUpdatedEventResponse extends BaseEventResponse {
        public BigInteger batchTimestamp;

        public byte[] listenerId;

        public String cid;
    }
}
