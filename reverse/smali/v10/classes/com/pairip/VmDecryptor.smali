.class final Lcom/pairip/VmDecryptor;
.super Ljava/lang/Object;
.source "VmDecryptor.java"


# direct methods
.method public constructor <init>()V
    .registers 1

    #@0
    .line 6
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    return-void
.end method


# virtual methods
.method public decrypt([BIZ)[B
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0,
            0x0
        }
        names = {
            "encryptedBytecode",
            "versionCode",
            "isDebuggingEnabled"
        }
    .end annotation

    #@0
    return-object p1
.end method
