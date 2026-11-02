/* Packaging control only: sign unchanged raw ZIP sections with the public test
 * key using Google's engine. No original APK Signing Block authentication is
 * copied. Existing ZIP entries (including old JAR metadata) are retained as
 * ordinary bytes. This does NOT sign or claim an original certificate. */
import com.android.apksig.DefaultApkSignerEngine;
import com.android.apksig.ApkSignerEngine;
import com.android.apksig.util.DataSources;
import java.io.*;
import java.nio.*;
import java.nio.channels.FileChannel;
import java.security.*;
import java.security.cert.X509Certificate;
import java.util.*;
public class RawZipSigner {
 static ByteBuffer le(byte[] a){return ByteBuffer.wrap(a).order(ByteOrder.LITTLE_ENDIAN);}
 static byte[] read(RandomAccessFile f,long offset,int size)throws IOException{
  byte[] a=new byte[size];f.seek(offset);f.readFully(a);return a;
 }
 static void copy(FileChannel in,FileChannel out,long offset,long count)throws IOException{
  while(count>0){long n=in.transferTo(offset,count,out);if(n<=0)throw new EOFException();offset+=n;count-=n;}
 }
 public static void main(String[] args)throws Exception {
  if(args.length!=3)throw new IllegalArgumentException("keystore input.apk output.apk");
  char[] password=System.getenv().getOrDefault("TEST_KEYSTORE_PASSWORD","changeit").toCharArray();
  String alias=System.getenv().getOrDefault("TEST_KEY_ALIAS","repaired");
  KeyStore ks=KeyStore.getInstance(new File(args[0]),password);
  PrivateKey key=(PrivateKey)ks.getKey(alias,password);
  List<X509Certificate> certificates=new ArrayList<>();
  for(java.security.cert.Certificate c:ks.getCertificateChain(alias))certificates.add((X509Certificate)c);
  DefaultApkSignerEngine.SignerConfig config=new DefaultApkSignerEngine.SignerConfig.Builder(alias,key,certificates).build();
  try(RandomAccessFile input=new RandomAccessFile(args[1],"r");
      DefaultApkSignerEngine engine=new DefaultApkSignerEngine.Builder(Collections.singletonList(config),24)
       .setV1SigningEnabled(false).setV2SigningEnabled(true).setV3SigningEnabled(true)
       .setOtherSignersSignaturesPreserved(false).build()) {
   long size=input.length(),tailStart=Math.max(0,size-65557);byte[] tail=read(input,tailStart,(int)(size-tailStart));
   int ep=-1;
   for(int i=tail.length-22;i>=0;i--)if(le(tail).getInt(i)==0x06054b50 && i+22+(le(tail).getShort(i+20)&65535)==tail.length){ep=i;break;}
   if(ep<0)throw new IOException("Missing EOCD");
   long eocd=tailStart+ep,cd=Integer.toUnsignedLong(le(tail).getInt(ep+16));
   byte[] footer=read(input,cd-24,24);
   if(!Arrays.equals(Arrays.copyOfRange(footer,8,24),"APK Sig Block 42".getBytes("US-ASCII")))throw new IOException("Missing signing block");
   long blockSize=le(footer).getLong(),start=cd-blockSize-8;
   if(start<0 || le(read(input,start,8)).getLong()!=blockSize)throw new IOException("Bad signing block");
   byte[] end=read(input,eocd,(int)(size-eocd));le(end).putInt(16,(int)start);
   ApkSignerEngine.OutputApkSigningBlockRequest2 request=engine.outputZipSections2(
    DataSources.asDataSource(input,0,start),DataSources.asDataSource(input,cd,eocd-cd),DataSources.asDataSource(le(end)));
   if(request.getPaddingSizeBeforeApkSigningBlock()!=0)throw new IOException("Engine requires new prefix padding");
   byte[] block=request.getApkSigningBlock();le(end).putInt(16,(int)(start+block.length));
   try(FileOutputStream output=new FileOutputStream(args[2])){
    copy(input.getChannel(),output.getChannel(),0,start);output.write(block);
    copy(input.getChannel(),output.getChannel(),cd,eocd-cd);output.write(end);
   }
   request.done();engine.outputDone();
   System.out.println("RAW_ZIP_SIGNED prefix="+start+" minSdk=24 oldSigningBlockAuthenticationCopied=false originalJarEntriesRetained=true");
  }
 }
}
