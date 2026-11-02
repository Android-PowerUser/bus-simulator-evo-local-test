import com.github.unidbg.AndroidEmulator;
import com.github.unidbg.arm.backend.Unicorn2Factory;
import com.github.unidbg.linux.android.AndroidEmulatorBuilder;
import com.github.unidbg.linux.android.AndroidResolver;
import com.github.unidbg.linux.android.dvm.*;
import com.github.unidbg.linux.android.dvm.array.*;
import com.github.unidbg.file.FileResult;
import com.github.unidbg.linux.file.SimpleFileIO;
import java.io.File;
import unicorn.Arm64Const;
import java.nio.file.Files;

/** Independent, fail-closed JNI/native-loader diagnostic, not a repaired APK.
 * No signature/installer/license results are faked or overridden.
 * Uses real Unidbg bionic/loader rather than the earlier hand-written PLT model.
 */
public class PairipNativeControl extends AbstractJni {
    private static final String PKG="com.Ovilex.BusSimulator2023";
    private static final String APK_PATH="/data/app/"+PKG+"/base.apk";
    private final File original;
    private final AndroidEmulator emulator;
    private final VM vm;
    private PairipNativeControl(File apk) {
        original=apk;
        emulator=AndroidEmulatorBuilder.for64Bit().setProcessName(PKG).addBackendFactory(new Unicorn2Factory(false)).build();
        emulator.setTimeout(60_000_000L);
        emulator.getSyscallHandler().setEnableThreadDispatcher(true);
        emulator.getMemory().setLibraryResolver(new AndroidResolver(23));
        emulator.getSyscallHandler().addIOResolver((emu,path,flags) ->
            APK_PATH.equals(path) ? FileResult.success(new SimpleFileIO(flags,original,path)) : null);
        vm=emulator.createDalvikVM(original);
        vm.setJni(this);
        vm.setVerbose(true);
    }
    @Override public int getStaticIntField(BaseVM base,DvmClass type,String signature) {
        if (signature.equals("android/os/Build$VERSION->SDK_INT:I")) return 23;
        return super.getStaticIntField(base,type,signature);
    }
    @Override public DvmObject<?> newObjectV(BaseVM base,DvmClass type,String sig,VaList args) {
        if(sig.equals("java/io/File-><init>(Ljava/lang/String;)V")) return type.newObject(args.getObjectArg(0).getValue());
        if(sig.equals("java/lang/Exception-><init>()V")) return type.newObject("emulated Java exception");
        if(sig.equals("java/lang/Long-><init>(J)V")) return type.newObject(args.getLongArg(0));
        return super.newObjectV(base,type,sig,args);
    }
    @Override public DvmObject<?> newObject(BaseVM base,DvmClass type,String sig,VarArg args) {
        if(sig.equals("java/io/File-><init>(Ljava/lang/String;)V")) return type.newObject(args.getObjectArg(0).getValue());
        if(sig.equals("java/lang/Exception-><init>()V")) return type.newObject("emulated Java exception");
        if(sig.equals("java/lang/Long-><init>(J)V")) return type.newObject(args.getLongArg(0));
        return super.newObject(base,type,sig,args);
    }
    @Override public long callLongMethodV(BaseVM base,DvmObject<?> object,String sig,VaList args) {
        if(sig.equals("java/io/File->length()J")) {
            String path=String.valueOf(object.getValue());
            if(path.startsWith("/proc/")) return 0;
            if(APK_PATH.equals(path)) return original.length();
            throw new UnsupportedOperationException("Unmodeled File.length: "+path);
        }
        return super.callLongMethodV(base,object,sig,args);
    }
    @Override public DvmObject<?> callObjectMethodV(BaseVM base,DvmObject<?> object,String sig,VaList args) {
        if(sig.equals("java/lang/Class->getResource(Ljava/lang/String;)Ljava/net/URL;"))
            return base.resolveClass("java/net/URL").newObject("jar:file:"+APK_PATH+"!/AndroidManifest.xml");
        if(sig.equals("java/net/URL->toString()Ljava/lang/String;")) return new StringObject(base,String.valueOf(object.getValue()));
        // Intentionally leave other calls fail-closed until their actual inputs
        // have been observed and modeled. Do not silently return null/false.
        return super.callObjectMethodV(base,object,sig,args);
    }
    private void requireReturn(String name) {
        long pc=emulator.getBackend().reg_read(Arm64Const.UC_ARM64_REG_PC).longValue();
        long expected=emulator.getReturnAddress();
        System.out.println("PHASE_END "+name+" pc="+Long.toHexString(pc)+" sentinel="+Long.toHexString(expected));
        if(pc!=expected) throw new IllegalStateException(name+" did not reach the return sentinel");
    }
    private void run(File library, File asset, boolean startup) throws Exception {
        System.out.println("INDEPENDENT_CONTROL original_apk="+original+" library="+library+" resolver_api=23");
        DalvikModule module=vm.loadLibrary(library,false);
        module.callJNI_OnLoad(emulator);
        requireReturn("JNI_OnLoad");
        System.out.println("JNI_ONLOAD_COMPLETED backend="+emulator.getBackend());
        if(startup) {
            DvmObject<?> result=vm.resolveClass("com/pairip/VMRunner").callStaticJniMethodObject(
                emulator,"executeVM([B[Ljava/lang/Object;)Ljava/lang/Object;",new ByteArray(vm,Files.readAllBytes(asset.toPath())),null);
            requireReturn("ERz startup");
            System.out.println("STARTUP_RETURNED "+result);
        }
        emulator.close();
    }
    public static void main(String[] args) throws Exception {
        if(args.length<3) throw new IllegalArgumentException("original-base.apk libpairipcore.so ERz-asset [startup]");
        new PairipNativeControl(new File(args[0])).run(new File(args[1]),new File(args[2]),args.length>3 && args[3].equals("startup"));
    }
}
