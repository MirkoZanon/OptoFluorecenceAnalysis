clear all
warning('off')
% Directory contaicl
ning the TSeries folders you want to convert:
path='\\cimec-storage\albhaa\haaalb001a1p\Data\Mirko Zanon Data\Raw Data\Drosophilae\';
dirpath = uigetdir(path)
dirlist=dir([dirpath,'\TSeries*']);
dirlist([dirlist.isdir]==0)=[];% select only directories
for d=1:length(dirlist) % directories
    for ch=1:2 % channels
        tstart=tic; %start timer
        % Obtain Input and Output filenames
        filelist=dir([dirlist(d).folder,'\',dirlist(d).name,'\*Ch',num2str(ch),'*tif*']);
        stackname=[dirlist(d).folder,'\',dirlist(d).name,'Ch',num2str(ch),'.tif'];
        [pathstr, fname, fext] = fileparts(stackname);
        if length(filelist)>0,% Allocate space
            infoimage=imfinfo([filelist(1).folder,'\',filelist(1).name]);
            width=infoimage.Width;
            height=infoimage.Height;
            numberimages=length(filelist);
            frames=zeros(height,width,numberimages,'uint16');
            % Read single frames
            for f =1:numberimages
                frames(:,:,f)=imread([filelist(f).folder,'\',filelist(f).name]);
            end
            tifformat= reshape(frames, height, width, 1, numberimages);
            % Write 3D tiff
            cd(pathstr);
            s=whos('frames'); %size bigger than 32byte?
            if s.bytes > 2^32-1
               tfile = Tiff([fname, fext], 'w8'); % Big Tiff file
            else
               tfile = Tiff([fname, fext], 'w');
            end
            tagstruct.ImageWidth = width;
            tagstruct.ImageLength = height;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample = 16;
            for f = 1:numberimages
                tfile.setTag(tagstruct);
                tfile.write(tifformat(:, :, :, f));
                if f ~= numberimages
                   tfile.writeDirectory();
                end
            end
            tfile.close();
            display(sprintf([fname,' converted in: %.3f s.'], toc(tstart)));
        else
            display([fname,' no Channel ',num2str(ch),' Data!'])
        end
    end
end
warning('on')